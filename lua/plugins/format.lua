-- Format on save with conform.nvim, falling back to the language server.
-- <leader>tf toggles it globally; vim.b.autoformat = false disables a buffer.
local js = { 'oxfmt' }

return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  cmd = 'ConformInfo',
  keys = {
    { '<C-A-l>', function() require('conform').format() end, mode = { 'n', 'x' }, desc = 'Reformat code' },
    { '<leader>cf', function() require('conform').format() end, mode = { 'n', 'x' }, desc = 'Reformat code' },
    {
      '<leader>tf',
      function()
        vim.g.autoformat = vim.g.autoformat == false
        vim.notify('Format on save: ' .. (vim.g.autoformat and 'on' or 'off'))
      end,
      desc = 'Toggle format on save',
    },
  },
  opts = {
    formatters_by_ft = {
      javascript = js,
      javascriptreact = js,
      typescript = js,
      typescriptreact = js,
      lua = { 'stylua' },
      go = { 'goimports', 'gofumpt' },
      rust = { 'rustfmt' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      python = { 'ruff_organize_imports', 'ruff_format' },
    },
    formatters = {
      -- Prefer the project's oxfmt over Mason's
      oxfmt = {
        command = function(self, ctx)
          return require('conform.util').from_node_modules('oxfmt')(self, ctx)
        end,
        args = { '--stdin-filepath', '$FILENAME' },
        stdin = true,
      },
    },
    default_format_opts = { lsp_format = 'fallback' },
    format_on_save = function(buf)
      if vim.g.autoformat == false or vim.b[buf].autoformat == false then
        return
      end
      return { timeout_ms = 2000 }
    end,
  },
}
