local group = vim.api.nvim_create_augroup('config', { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd('TextYankPost', {
  group = group,
  callback = function() vim.hl.on_yank() end,
})

-- Save on focus loss; reload files changed outside nvim on focus gain.
autocmd('FocusLost', { group = group, command = 'silent! wall' })
autocmd({ 'FocusGained', 'BufEnter' }, { group = group, command = 'silent! checktime' })

-- Reopen files at the last cursor position.
autocmd('BufReadPost', {
  group = group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close transient windows with q.
autocmd('FileType', {
  group = group,
  pattern = { 'help', 'qf', 'checkhealth', 'man', 'lspinfo' },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = args.buf, silent = true })
  end,
})

-- Keep splits balanced when the terminal resizes.
autocmd('VimResized', { group = group, command = 'tabdo wincmd =' })
