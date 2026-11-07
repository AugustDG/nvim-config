local map = vim.keymap.set

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Move by display line when no count is given
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Save (Ctrl-S)
map({ 'n', 'i', 'x' }, '<C-s>', '<cmd>silent! wall<CR><Esc>', { desc = 'Save all' })

-- Comment line/selection (Ctrl-/); some terminals send Ctrl-_ for it
for _, lhs in ipairs({ '<C-/>', '<C-_>' }) do
  map('n', lhs, 'gcc', { remap = true, desc = 'Toggle comment' })
  map('x', lhs, 'gc', { remap = true, desc = 'Toggle comment' })
end

-- Move line/selection (Alt-Shift-Up/Down)
map('n', '<A-S-Up>', '<cmd>move .-2<CR>==', { desc = 'Move line up' })
map('n', '<A-S-Down>', '<cmd>move .+1<CR>==', { desc = 'Move line down' })
map('x', '<A-S-Up>', ":move '<-2<CR>gv=gv", { silent = true, desc = 'Move selection up' })
map('x', '<A-S-Down>', ":move '>+1<CR>gv=gv", { silent = true, desc = 'Move selection down' })

-- Keep selection when indenting
map('x', '<', '<gv')
map('x', '>', '>gv')

-- Diagnostics (F2 / Shift-F2: next / previous problem)
map('n', '<F2>', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next problem' })
map('n', '<S-F2>', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Previous problem' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

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
