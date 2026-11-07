local map = vim.keymap.set

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Move by display line when no count is given
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

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

-- Move mode (<leader>m): j/k or Up/Down keep moving the line or selection; any
-- other key exits (and runs, unless it is Esc). All moves undo as one step.
local function move_mode()
  local visual = vim.fn.mode():match('[vV\22]') ~= nil
  if visual then
    vim.cmd('normal! \27') -- leave visual so '< and '> are set
  end
  local up, down = vim.keycode('<Up>'), vim.keycode('<Down>')
  local moved = false
  while true do
    vim.api.nvim_echo({ { '-- MOVE -- j/k to move, any other key to exit', 'ModeMsg' } }, false, {})
    vim.cmd.redraw()
    local ok, key = pcall(vim.fn.getcharstr)
    local dir = ok and ((key == 'j' or key == down) and 1 or (key == 'k' or key == up) and -1) or nil
    if not dir then
      if ok and key ~= '\27' then
        vim.api.nvim_feedkeys(key, 'm', false)
      end
      break
    end
    if moved then
      pcall(vim.cmd.undojoin)
    end
    local range = visual and "'<,'>" or '.'
    local target = dir == 1 and (visual and "'>+1" or '.+1') or (visual and "'<-2" or '.-2')
    if pcall(vim.cmd, ('silent %smove %s'):format(range, target)) then
      moved = true
      vim.cmd(visual and "silent normal! '<=']" or 'silent normal! ==')
    end
  end
  vim.api.nvim_echo({ { '' } }, false, {})
  if visual then
    vim.cmd('normal! gv')
  end
end
map({ 'n', 'x' }, '<leader>m', move_mode, { desc = 'Move mode (j/k)' })

-- Keep selection when indenting
map('x', '<', '<gv')
map('x', '>', '>gv')

-- Diagnostics (F2 / Shift-F2: next / previous problem)
map('n', '<F2>', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next problem' })
map('n', '<S-F2>', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Previous problem' })
map('n', '<leader>dn', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next problem' })
map('n', '<leader>dp', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Previous problem' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

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
