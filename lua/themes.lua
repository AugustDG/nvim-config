-- [[ Configure Color Scheme ]]
local function is_dark_mode()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:match("Dark") ~= nil
  end
  return true
end

local dark = is_dark_mode()

require("onedarkpro").setup({
  options = {
    highlight_inactive_windows = true,
    transparency = true,
  },
})

vim.o.background = dark and "dark" or "light"
vim.cmd.colorscheme(dark and "onedark_dark" or "onelight")
