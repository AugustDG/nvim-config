return {
  'saghen/blink.cmp',
  version = '1.*', -- release tags ship the prebuilt fuzzy matcher
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = { 'rafamadriz/friendly-snippets' },
  opts = {
    keymap = {
      preset = 'none',
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<Tab>'] = { 'accept', 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-Up>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-Down>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },
    completion = {
      list = { selection = { preselect = true, auto_insert = false } },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = {
        draw = { columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'source_name' } } },
      },
    },
    signature = { enabled = true },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
      providers = {
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
      },
    },
    cmdline = {
      keymap = { preset = 'cmdline', ['<Tab>'] = { 'show_and_insert', 'select_next' } },
      completion = { menu = { auto_show = true } },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
}
