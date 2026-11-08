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
o.tabclose = 'uselast' -- closing a tab returns to the previously used one
o.winborder = 'rounded'
o.pumheight = 12
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.fillchars = { eob = ' ', fold = ' ', foldopen = '\u{f078}', foldclose = '\u{f054}', foldsep = ' ' }

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

-- Folds from treesitter, all open by default
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldtext = '' -- show the first line with its highlighting
o.foldlevel = 99
o.foldlevelstart = 99

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
