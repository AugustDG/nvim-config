-- Sessions per directory and git branch. Starting `nvim` with no arguments
-- restores the session for the working directory, as Zed reopens a project.
return {
  'folke/persistence.nvim',
  lazy = false,
  keys = {
    { '<leader>ps', function() require('persistence').load() end, desc = 'Restore session (this directory)' },
    { '<leader>pl', function() require('persistence').load({ last = true }) end, desc = 'Restore last session' },
    { '<leader>pS', function() require('persistence').select() end, desc = 'Select session' },
    { '<leader>pd', function() require('persistence').stop() end, desc = "Don't save this session" },
  },
  opts = {},
  config = function(_, opts)
    vim.opt.sessionoptions = { 'buffers', 'curdir', 'folds', 'globals', 'tabpages', 'winsize', 'skiprtp' }
    local persistence = require('persistence')
    persistence.setup(opts)

    local group = vim.api.nvim_create_augroup('config-session', { clear = true })

    -- Tool views (git tabs, quickfix, explorer, ...) don't restore cleanly
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = 'PersistenceSavePre',
      callback = function()
        require('config.close').close_all_tools()
      end,
    })

    vim.api.nvim_create_autocmd('StdinReadPre', {
      group = group,
      callback = function()
        vim.g.started_with_stdin = true
      end,
    })
    vim.api.nvim_create_autocmd('VimEnter', {
      group = group,
      nested = true, -- so restored buffers trigger FileType, LSP, treesitter
      callback = function()
        if vim.fn.argc(-1) == 0 and not vim.g.started_with_stdin then
          persistence.load()
        end
      end,
    })
  end,
}
