-- Leader must be set before lazy.nvim loads plugins.
vim.g.maplocalleader = ' '
vim.g.mapleader = ' '

require('config.options')
require('config.clipboard')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')
