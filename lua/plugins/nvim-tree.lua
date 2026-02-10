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
    {
      "b0o/nvim-tree-preview.lua",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
    },
  },
  config = function()
    local api = require('nvim-tree.api')

    local function on_attach(bufnr)
      api.config.mappings.default_on_attach(bufnr)

      local function tree_opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      local preview = require('nvim-tree-preview')

      vim.keymap.set('n', 'P', preview.watch, tree_opts('Preview (Watch)'))
      vim.keymap.set('n', '<Esc>', preview.unwatch, tree_opts('Close Preview/Unwatch'))
      vim.keymap.set('n', '<C-f>', function() return preview.scroll(4) end, tree_opts('Scroll Down'))
      vim.keymap.set('n', '<C-b>', function() return preview.scroll(-4) end, tree_opts('Scroll Up'))
      vim.keymap.set('n', '<Tab>', preview.node_under_cursor, tree_opts('Preview'))
    end

    require("nvim-tree").setup({
      on_attach = on_attach,
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
