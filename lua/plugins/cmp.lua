-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require('cmp')

cmp.setup({
  snippet = {},
  window = {
    border = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered()
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Up>'] = cmp.mapping.scroll_docs(-4),
    ['<C-Down>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<Tab>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.complete_common_string()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
  },
})

return {}
