-- Language servers: Mason installs binaries, nvim-lspconfig ships the server
-- definitions (lsp/*.lua), and vim.lsp.config/enable wires them up.

-- Mason packages: servers, formatters, and parser tooling.
local tools = {
  'vtsls',
  'oxlint',
  'oxfmt',
  'rust-analyzer',
  'gopls',
  'goimports',
  'gofumpt',
  'clangd',
  'clang-format',
  'basedpyright',
  'ruff',
  'lua-language-server',
  'stylua',
  'tree-sitter-cli',
}

-- vim.lsp server names to enable (when their binary is available).
local servers = {
  'vtsls',
  'oxlint',
  'rust_analyzer',
  'gopls',
  'clangd',
  'basedpyright',
  'ruff',
  'lua_ls',
}

local function configure_servers()
  vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities({
      workspace = { fileOperations = { didRename = true, willRename = true } },
    }),
  })

  local ts_settings = {
    updateImportsOnFileMove = { enabled = 'always' },
    inlayHints = {
      parameterNames = { enabled = 'literals' },
      variableTypes = { enabled = false },
      functionLikeReturnTypes = { enabled = true },
    },
  }
  vim.lsp.config('vtsls', {
    settings = {
      typescript = ts_settings,
      javascript = ts_settings,
      vtsls = { autoUseWorkspaceTsdk = true },
    },
  })

  vim.lsp.config('rust_analyzer', {
    settings = {
      ['rust-analyzer'] = { check = { command = 'clippy' } },
    },
  })

  vim.lsp.config('gopls', {
    settings = {
      gopls = {
        gofumpt = true,
        staticcheck = true,
        hints = { parameterNames = true, compositeLiteralFields = true },
      },
    },
  })

  vim.lsp.config('clangd', {
    cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=iwyu', '--completion-style=detailed' },
  })

  vim.lsp.config('basedpyright', {
    settings = {
      basedpyright = { analysis = { typeCheckingMode = 'standard' } },
    },
  })

  vim.lsp.config('lua_ls', {
    settings = {
      Lua = { workspace = { checkThirdParty = false }, telemetry = { enable = false } },
    },
  })
end

-- Enable every server whose binary is on PATH. Rerun after Mason installs.
local function enable_servers()
  for _, name in ipairs(servers) do
    local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
    if type(cmd) ~= 'table' or vim.fn.executable(cmd[1]) == 1 then
      vim.lsp.enable(name)
    end
  end
end

local function on_attach(args)
  local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
  local buf = args.buf
  local function map(modes, lhs, rhs, desc)
    vim.keymap.set(modes, lhs, rhs, { buffer = buf, desc = desc })
  end

  -- basedpyright handles hover for Python
  if client.name == 'ruff' then
    client.server_capabilities.hoverProvider = false
  end

  -- Navigation, with results in snacks.picker
  local function pick(source)
    return function()
      Snacks.picker[source]()
    end
  end
  map('n', 'gd', pick('lsp_definitions'), 'Go to definition')
  map('n', 'gD', pick('lsp_declarations'), 'Go to declaration')
  map('n', 'grr', pick('lsp_references'), 'Find usages')
  map('n', 'gri', pick('lsp_implementations'), 'Go to implementation')
  map('n', 'grt', pick('lsp_type_definitions'), 'Go to type definition')

  -- JetBrains chords, each with a leader equivalent
  map({ 'n', 'x' }, '<A-CR>', vim.lsp.buf.code_action, 'Code action')
  map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
  map('n', '<S-F6>', vim.lsp.buf.rename, 'Rename')
  map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename')
  map('n', '<A-F7>', pick('lsp_references'), 'Find usages')
  map('n', '<leader>cu', pick('lsp_references'), 'Find usages')
  map('n', '<C-A-b>', pick('lsp_implementations'), 'Go to implementation')
  map('n', '<leader>ci', pick('lsp_implementations'), 'Go to implementation')
  map('n', '<C-S-b>', pick('lsp_type_definitions'), 'Go to type definition')
  map('n', '<leader>ct', pick('lsp_type_definitions'), 'Go to type definition')
  map('n', '<leader>cs', pick('lsp_incoming_calls'), 'Call hierarchy (incoming)')

  if client:supports_method('textDocument/inlayHint') then
    map('n', '<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
    end, 'Toggle inlay hints')
  end

  -- Highlight other references of the symbol under the cursor
  if client:supports_method('textDocument/documentHighlight') then
    local group = vim.api.nvim_create_augroup('config-lsp-highlight-' .. buf, { clear = true })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { group = group, buffer = buf, callback = vim.lsp.buf.document_highlight })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { group = group, buffer = buf, callback = vim.lsp.buf.clear_references })
  end
end

return {
  {
    'mason-org/mason.nvim',
    lazy = false, -- puts Mason's bin dir on PATH for servers and formatters
    build = ':MasonUpdate',
    opts = {},
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    event = 'VeryLazy',
    dependencies = { 'mason-org/mason.nvim' },
    opts = { ensure_installed = tools, run_on_start = true },
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'mason-org/mason.nvim', 'saghen/blink.cmp' },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        virtual_text = { spacing = 2, source = 'if_many' },
        float = { source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '\u{f057}',
            [vim.diagnostic.severity.WARN] = '\u{f071}',
            [vim.diagnostic.severity.INFO] = '\u{f05a}',
            [vim.diagnostic.severity.HINT] = '\u{f0eb}',
          },
        },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
        callback = on_attach,
      })

      configure_servers()
      enable_servers()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MasonToolsUpdateCompleted',
        callback = vim.schedule_wrap(enable_servers),
      })
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } },
  },
}
