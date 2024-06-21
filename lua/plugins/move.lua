require('move').setup({
  line = {
    enable = true,
    indent = true,
  },
  block = {
    enable = true,
    indent = true,
  },
  word = {
    enable = true,
  },
  char = {
    enable = true,
  },
})

local opts = { noremap = true, silent = true }

-- Normal-mode commands
vim.keymap.set('n', '<M-j>', ':MoveLine(-1)<CR>', opts)
vim.keymap.set('n', '<M-k>', ':MoveLine(1)<CR>', opts)
vim.keymap.set('n', '<M-h>', ':MoveHChar(-1)<CR>', opts)
vim.keymap.set('n', '<M-l>', ':MoveHChar(1)<CR>', opts)

vim.keymap.set('n', '<M-Up>', ':MoveLine(-1)<CR>', opts)
vim.keymap.set('n', '<M-Down>', ':MoveLine(1)<CR>', opts)
vim.keymap.set('n', '<M-Left>', ':MoveHChar(-1)<CR>', opts)
vim.keymap.set('n', '<M-Right>', ':MoveHChar(1)<CR>', opts)

vim.keymap.set('n', '<leader>wf', ':MoveWord(1)<CR>', opts)
vim.keymap.set('n', '<leader>wb', ':MoveWord(-1)<CR>', opts)

-- Visual-mode commands
vim.keymap.set('v', '<M-j>', ':MoveBlock(-1)<CR>', opts)
vim.keymap.set('v', '<M-k>', ':MoveBlock(1)<CR>', opts)
vim.keymap.set('v', '<M-h>', ':MoveHBlock(-1)<CR>', opts)
vim.keymap.set('v', '<M-l>', ':MoveHBlock(1)<CR>', opts)

vim.keymap.set('v', '<M-Up>', ':MoveBlock(-1)<CR>', opts)
vim.keymap.set('v', '<M-Down>', ':MoveBlock(1)<CR>', opts)
vim.keymap.set('v', '<M-Left>', ':MoveHBlock(-1)<CR>', opts)
vim.keymap.set('v', '<M-Right>', ':MoveHBlock(1)<CR>', opts)

return {}
