local map = vim.keymap.set
local submode = require('config.submode')

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- Esc: clear multicursor cursors, else close the tool view (float, git tab,
-- quickfix, help, ...) and return to the previous view, else clear search
-- highlight.
map('n', '<Esc>', function()
  local mc = package.loaded['multicursor-nvim']
  if mc and mc.hasCursors() then
    if mc.cursorsEnabled() then
      mc.clearCursors()
    else
      mc.enableCursors()
    end
  elseif not require('config.close').close() then
    vim.cmd.nohlsearch()
  end
end, { desc = 'Clear cursors / close tool view / clear highlight' })

-- Move by display line when no count is given
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Wheel over a scroll-bound window (diff panes) focuses it first, since
-- scrollbind only follows the current window.
for _, key in ipairs({ '<ScrollWheelUp>', '<ScrollWheelDown>' }) do
  local raw = vim.keycode(key)
  map({ 'n', 'x' }, key, function()
    local win = vim.fn.getmousepos().winid
    if win ~= 0 and win ~= vim.api.nvim_get_current_win() and vim.wo[win].scrollbind then
      vim.api.nvim_set_current_win(win)
    end
    vim.api.nvim_feedkeys(raw, 'in', false)
  end, { desc = 'Scroll (keeps scroll-bound panes in sync)' })
end

-- Save (Ctrl-S)
map({ 'n', 'i', 'x' }, '<C-s>', '<cmd>silent! wall<CR><Esc>', { desc = 'Save all' })
map('n', '<leader>w', '<cmd>silent! wall<CR>', { desc = 'Save all' })

-- Comment line/selection (Ctrl-/); some terminals send Ctrl-_ for it
for _, lhs in ipairs({ '<C-/>', '<C-_>' }) do
  map('n', lhs, 'gcc', { remap = true, desc = 'Toggle comment' })
  map('x', lhs, 'gc', { remap = true, desc = 'Toggle comment' })
end
map('n', '<leader>/', 'gcc', { remap = true, desc = 'Toggle comment' })
map('x', '<leader>/', 'gc', { remap = true, desc = 'Toggle comment' })

-- Move line/selection (Alt-Shift-Up/Down)
map('n', '<A-S-Up>', '<cmd>move .-2<CR>==', { desc = 'Move line up' })
map('n', '<A-S-Down>', '<cmd>move .+1<CR>==', { desc = 'Move line down' })
map('x', '<A-S-Up>', ":move '<-2<CR>gv=gv", { silent = true, desc = 'Move selection up' })
map('x', '<A-S-Down>', ":move '>+1<CR>gv=gv", { silent = true, desc = 'Move selection down' })

-- Move mode (<leader>m, then j/k): moves undo as one step.
local function move(dir)
  return function(ctx)
    local range = ctx.visual and "'<,'>" or '.'
    local target = dir > 0 and (ctx.visual and "'>+1" or '.+1') or (ctx.visual and "'<-2" or '.-2')
    vim.cmd(('silent %smove %s'):format(range, target))
    vim.cmd(ctx.visual and "silent normal! '<=']" or 'silent normal! ==')
  end
end
map({ 'n', 'x' }, '<leader>m', submode.create({
  name = 'MOVE',
  join_undo = true,
  keys = {
    { { 'j', '<Down>' }, move(1), 'down' },
    { { 'k', '<Up>' }, move(-1), 'up' },
  },
}), { desc = 'Move mode' })

-- Keep selection when indenting
map('x', '<', '<gv')
map('x', '>', '>gv')

-- Diagnostics (F2 / Shift-F2: next / previous problem)
map('n', '<F2>', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next problem' })
map('n', '<S-F2>', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Previous problem' })
map('n', '<leader>d', submode.create({
  name = 'PROBLEMS',
  keys = {
    { { 'n', 'j', '<Down>' }, function() vim.diagnostic.jump({ count = 1, float = true }) end, 'next' },
    { { 'p', 'k', '<Up>' }, function() vim.diagnostic.jump({ count = -1, float = true }) end, 'prev' },
  },
}), { desc = 'Problems mode' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Line diagnostics' })

-- xterm-style terminals send Shift-F1..F12 as F13..F24 and Ctrl-F1..F12 as
-- F25..F36. Alias them so <S-Fn> and <C-Fn> mappings work everywhere.
for i = 1, 12 do
  map({ 'n', 'i', 'x', 'o' }, ('<F%d>'):format(i + 12), ('<S-F%d>'):format(i), { remap = true })
  map({ 'n', 'i', 'x', 'o' }, ('<F%d>'):format(i + 24), ('<C-F%d>'):format(i), { remap = true })
end

-- Show how key chords reach nvim, to check what the terminal and tmux pass through.
vim.api.nvim_create_user_command('KeyTest', function()
  local seen = {}
  while true do
    vim.api.nvim_echo({ { 'KeyTest (Esc to quit): ' .. table.concat(seen, '  ') } }, false, {})
    vim.cmd.redraw()
    local ok, key = pcall(vim.fn.getcharstr)
    if not ok then break end
    local name = vim.fn.keytrans(key)
    if name == '<Esc>' then break end
    table.insert(seen, name)
  end
  vim.api.nvim_echo({ { 'KeyTest: ' .. table.concat(seen, '  ') } }, true, {})
end, { desc = 'Echo received key chords' })
