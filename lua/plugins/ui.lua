return {
  {
    'nvim-mini/mini.icons',
    lazy = true,
    opts = {},
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        theme = 'auto',
        globalstatus = true,
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      spec = {
        { '<leader>c', group = 'Code' },
        { '<leader>f', group = 'Files' },
        { '<leader>g', group = 'Git' },
        { '<leader>h', group = 'Hunks' },
        { '<leader>s', group = 'Search' },
        { '<leader>t', group = 'Toggle' },
        { '<leader>x', group = 'Lists' },
      },
    },
  },
}
