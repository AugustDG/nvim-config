require("telescope").setup({
  extensions = {
    file_browser = {
      hidden = true,
      grouped = true,
      depth = 3,
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
    },
  },
})

-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require("telescope").load_extension("file_browser")

local file_browser = require("telescope").extensions.file_browser

vim.keymap.set("n", "<space>sf", file_browser.file_browser, { desc = "[S]earch [F]ile browser" })

return {}
