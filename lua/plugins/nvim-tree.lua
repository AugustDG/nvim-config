local function opts(desc)
  return { desc = "nvim-tree: " .. desc, noremap = true, silent = true, nowait = true }
end

-- custom mappings
vim.keymap.set('n', '<leader>sf',
  function()
    local api = require('nvim-tree.api')

    if (api.tree.is_tree_buf()) then
      api.tree.close()
    else
      api.tree.focus()
    end
  end, opts("Toggle nvim-tree"))

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      create_in_closed_folder = true,
      sync_root_with_cwd = true,
      view = {
        adaptive_size = true,
        width = 50,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    })
  end,
}
