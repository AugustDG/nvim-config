-- Sync with the system clipboard. Over SSH, or when no native clipboard tool
-- exists, copy through OSC 52 so the local terminal (via tmux) receives it.
vim.opt.clipboard = 'unnamedplus'

local native = { 'pbcopy', 'wl-copy', 'xclip', 'xsel', 'win32yank.exe' }
local has_native = vim.iter(native):any(function(bin)
  return vim.fn.executable(bin) == 1
end)

if vim.env.SSH_TTY or not has_native then
  local osc52 = require('vim.ui.clipboard.osc52')
  -- Most terminals refuse OSC 52 reads; paste from nvim's own register and
  -- use the terminal's paste for external text.
  local function paste()
    return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
  end
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = { ['+'] = paste, ['*'] = paste },
  }
end
