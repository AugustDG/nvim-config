require("telescope").setup {
  extensions = {
    file_browser = {
      grouped = true,
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
    },
  },
}

-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require("telescope").load_extension "file_browser"

vim.api.nvim_set_keymap(
  "n",
  "<space>fb",
  ":Telescope file_browser<CR>",
  { noremap = true, desc = "Open file browser" }
)

-- open file_browser with the path of the current buffer
vim.api.nvim_set_keymap(
  "n",
  "<space>fb",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true, desc = "Open file browser (with buffer path)" }
)

return {}
