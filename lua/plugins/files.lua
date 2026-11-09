-- File navigation: yazi in a float (also replaces netrw for directories),
-- with snacks.explorer as a sidebar tree.
return {
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim', 'folke/snacks.nvim' },
    keys = {
      { '-', '<cmd>Yazi<CR>', desc = 'Yazi (current file)' },
      { '<leader>fy', '<cmd>Yazi cwd<CR>', desc = 'Yazi (working directory)' },
      { '<leader>fY', '<cmd>Yazi toggle<CR>', desc = 'Resume last Yazi' },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1 -- yazi opens directories instead
    end,
    opts = {
      open_for_directories = true,
      floating_window_scaling_factor = 0.9,
      yazi_floating_window_border = 'rounded',
      keymaps = { show_help = '<F1>' },
      integrations = {
        grep_in_directory = function(directory)
          Snacks.picker.grep({ dirs = { directory } })
        end,
        grep_in_selected_files = function(selected_files)
          local paths = vim.tbl_map(function(f) return f.filename end, selected_files)
          Snacks.picker.grep({ dirs = paths })
        end,
      },
    },
  },
  {
    'folke/snacks.nvim',
    keys = {
      { '<A-1>', function() Snacks.explorer() end, desc = 'Project tree' },
      { '<leader>fe', function() Snacks.explorer() end, desc = 'Project tree' },
    },
    opts = {
      explorer = { replace_netrw = false }, -- yazi handles directories
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            win = {
              list = {
                keys = {
                  ['<Right>'] = 'confirm', -- like l
                  ['<Left>'] = 'explorer_close', -- like h
                },
              },
            },
          },
        },
      },
    },
  },
}
