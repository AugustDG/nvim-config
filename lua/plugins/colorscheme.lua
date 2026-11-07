-- Follow the terminal: nvim queries its background (OSC 11) at startup and
-- sets 'background'; tmux answers with the outer terminal's colors.
local function apply()
  local name = vim.o.background == 'light' and 'onelight' or 'onedark_dark'
  if vim.g.colors_name ~= name then
    vim.cmd.colorscheme(name)
  end
end

return {
  'olimorris/onedarkpro.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('onedarkpro').setup({
      options = {
        transparency = true,
        highlight_inactive_windows = true,
      },
    })
    apply()
    vim.api.nvim_create_autocmd('OptionSet', {
      group = vim.api.nvim_create_augroup('config-theme', { clear = true }),
      pattern = 'background',
      callback = function() vim.schedule(apply) end,
    })
  end,
}
