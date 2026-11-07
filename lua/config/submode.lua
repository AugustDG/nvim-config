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
-- Actions receive ctx.visual: true when entered from visual mode. In that case
-- the selection is available as '< and '> and is reselected on exit.
local M = {}

function M.create(spec)
  local actions, hints = {}, {}
  for _, entry in ipairs(spec.keys) do
    local lhs, fn, desc = entry[1], entry[2], entry[3]
    lhs = type(lhs) == 'table' and lhs or { lhs }
    for _, k in ipairs(lhs) do
      actions[vim.keycode(k)] = fn
    end
    table.insert(hints, ('%s %s'):format(lhs[1], desc))
  end
  local hint = ('-- %s -- %s  (other key exits)'):format(spec.name, table.concat(hints, '  '))

  return function()
    local ctx = { visual = vim.fn.mode():match('[vV\22]') ~= nil }
    if ctx.visual then
      vim.cmd('normal! \27') -- leave visual so '< and '> are set
    end
    local acted = false
    while true do
      vim.api.nvim_echo({ { hint, 'ModeMsg' } }, false, {})
      vim.cmd.redraw()
      local ok, key = pcall(vim.fn.getcharstr)
      local fn = ok and actions[key]
      if not fn then
        if ok and key ~= '\27' then
          vim.api.nvim_feedkeys(key, 'm', false)
        end
        break
      end
      if spec.join_undo and acted then
        pcall(vim.cmd.undojoin)
      end
      acted = pcall(fn, ctx) or acted
    end
    vim.api.nvim_echo({ { '' } }, false, {})
    if ctx.visual then
      vim.cmd('normal! gv')
    end
  end
end

return M
