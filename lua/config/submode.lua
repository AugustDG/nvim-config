-- Submodes: a leader key enters a mode where single keys repeat an action
-- until any other key is pressed. Esc just exits; other keys exit and run.
--
--   submode.create({
--     name = 'MOVE',
--     join_undo = true, -- consecutive actions undo as one step
--     keys = {
--       { { 'j', '<Down>' }, function(ctx) ... end, 'down' },
--     },
--   })
--
-- Actions receive ctx.visual: true when entered from visual mode. By default
-- visual mode is left so '< and '> are set, and the selection is reselected on
-- exit. With visual = 'keep', visual mode stays active for the actions.
-- With esc = 'pass', Esc is not captured: it exits the mode and keeps its
-- usual meaning (e.g. multicursor's Esc clears the cursors).
--
-- Mode keys are temporary mappings, so actions may feed keys (as plugins
-- like multicursor do). vim.on_key watches typed keys only: the first key that
-- is not a mode key ends the mode and then runs normally. When the selection
-- must be restored first, that key (and anything typed while the mode closes)
-- is held back and replayed after reselecting.
local M = {}

local ns = vim.api.nvim_create_namespace('config.submode')
local esc = vim.keycode('<Esc>')
local modes = { 'n', 'x' }

function M.create(spec)
  local entries, hints, mode_keys = {}, {}, {}
  for _, entry in ipairs(spec.keys) do
    local lhs = type(entry[1]) == 'table' and entry[1] or { entry[1] }
    for _, k in ipairs(lhs) do
      table.insert(entries, { lhs = k, fn = entry[2] })
      mode_keys[vim.keycode(k)] = true
    end
    table.insert(hints, ('%s %s'):format(lhs[1], entry[3]))
  end
  local pass_esc = spec.esc == 'pass'
  local hint = ('-- %s -- %s  (%s)'):format(
    spec.name,
    table.concat(hints, '  '),
    pass_esc and 'Esc cancels, other key exits' or 'other key exits'
  )

  local active = false

  local function echo(text)
    -- Truncate so a long hint never triggers a hit-enter prompt
    local width = vim.o.columns - 1
    if vim.fn.strdisplaywidth(text) > width then
      text = vim.fn.strcharpart(text, 0, width - 1) .. '…'
    end
    vim.api.nvim_echo({ { text, 'ModeMsg' } }, false, {})
  end

  return function()
    if active then
      return
    end
    active = true

    local ctx = { visual = vim.fn.mode():match('[vV\22]') ~= nil }
    local marks = ctx.visual and spec.visual ~= 'keep'
    if marks then
      vim.cmd('normal! \27') -- leave visual so '< and '> are set
    end

    -- Install mode mappings, saving whatever they shadow
    local saved, acted = {}, false
    for _, e in ipairs(entries) do
      for _, mode in ipairs(modes) do
        local prev = vim.fn.maparg(e.lhs, mode, false, true)
        table.insert(saved, { mode = mode, lhs = e.lhs, prev = (prev.buffer == 0 and prev.lhs) and prev or nil })
        vim.keymap.set(mode, e.lhs, function()
          if spec.join_undo and acted then
            pcall(vim.cmd.undojoin)
          end
          acted = pcall(e.fn, ctx) or acted
          echo(hint)
        end, { nowait = true })
      end
    end

    local pending, closing = {}, false
    local function finish()
      active = false
      vim.on_key(nil, ns)
      for _, s in ipairs(saved) do
        pcall(vim.keymap.del, s.mode, s.lhs)
        if s.prev then
          vim.fn.mapset(s.prev)
        end
      end
      echo('')
      -- Feed at the front of typeahead, so these run before later keys
      local replay = table.concat(pending)
      if replay ~= '' then
        vim.api.nvim_feedkeys(replay, 'mit', false)
      end
      if marks then
        vim.api.nvim_feedkeys('gv', 'ni', false)
      end
    end

    -- Esc only leaves the mode
    for _, mode in ipairs(pass_esc and {} or modes) do
      local prev = vim.fn.maparg('<Esc>', mode, false, true)
      table.insert(saved, { mode = mode, lhs = '<Esc>', prev = (prev.buffer == 0 and prev.lhs) and prev or nil })
      vim.keymap.set(mode, '<Esc>', function()
        if not closing then
          closing = true
          finish()
        end
      end, { nowait = true })
    end

    vim.on_key(function(_, typed)
      if typed == '' or closing then
        if closing and marks and typed ~= '' then
          table.insert(pending, typed)
          return ''
        end
        return -- fed by an action or plugin
      end
      if mode_keys[typed] or (typed == esc and not pass_esc) then
        return -- handled by a mode mapping
      end
      closing = true
      vim.schedule(finish)
      if marks then
        table.insert(pending, typed)
        return '' -- replayed after the selection is restored
      end
    end, ns)

    echo(hint)
  end
end

return M
