local o = vim.opt

-- UI
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = 'yes'
o.showmode = false -- shown in the statusline
o.laststatus = 3 -- one global statusline
o.wrap = false
o.scrolloff = 8
o.sidescrolloff = 8
o.smoothscroll = true
o.splitright = true
o.splitbelow = true
o.winborder = 'rounded'
o.pumheight = 12
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.fillchars = { eob = ' ' }

-- Editing
o.mouse = 'a'
o.breakindent = true
o.undofile = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.virtualedit = 'block'
o.confirm = true

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = 'split' -- live preview of :s in a split

-- Files: save when leaving buffers, reload when changed on disk
o.autowriteall = true
o.autoread = true
-- Trusted per-project config (.nvim.lua, .nvimrc), prompted via :trust
o.exrc = true

-- Timing
o.updatetime = 250
o.timeoutlen = 300
