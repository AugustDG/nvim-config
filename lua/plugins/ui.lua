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
        disabled_filetypes = { statusline = { 'snacks_dashboard' } },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', path = 1, symbols = { modified = '●', readonly = '\u{f023}' } } },
        lualine_x = {
          'diagnostics',
          {
            function()
              local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
              return table.concat(names, ' ')
            end,
            icon = '\u{f085}',
          },
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },
  {
    -- Breadcrumbs (file path and symbol path) in the winbar, as in Zed
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    keys = {
      { '<A-Home>', function() require('dropbar.api').pick() end, desc = 'Navigation bar' },
      { '<leader>fn', function() require('dropbar.api').pick() end, desc = 'Navigation bar' },
    },
    opts = {},
  },
  {
    'folke/snacks.nvim',
    opts = {
      notifier = { enabled = true, timeout = 3000 },
      indent = { enabled = true, animate = { enabled = false } },
      statuscolumn = { enabled = true, folds = { open = false, git_hl = true } },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
    },
    keys = {
      { '<leader>sn', function() Snacks.notifier.show_history() end, desc = 'Notification history' },
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
        { '<leader>p', group = 'Session' },
        { '<leader>s', group = 'Search' },
        { '<leader>t', group = 'Toggle' },
        { '<leader>x', group = 'Lists' },
      },
    },
  },
}
