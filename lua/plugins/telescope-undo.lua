require("telescope").setup({
  extensions = {
    undo = {
      -- telescope-undo.nvim config, see below
    },
    -- other extensions:
    -- file_browser = { ... }
  },
})
require("telescope").load_extension("undo")

vim.api.nvim_set_keymap("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "[U]ndo History" })

return {}
