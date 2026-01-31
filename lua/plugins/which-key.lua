return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    spec = {
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>g', group = '[G]it' },
      { '<leader>h', group = 'Git [H]unk' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>h', group = 'Git [H]unk', mode = 'v' },
    },
  },
}
