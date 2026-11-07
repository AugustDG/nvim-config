-- nvim-treesitter (main branch): installs parsers; highlighting, folds and
-- indent come from Nvim's built-in treesitter.
local ensure = {
  'bash', 'c', 'cpp', 'css', 'diff', 'go', 'gomod', 'html', 'javascript', 'jsdoc', 'json',
  'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query', 'regex', 'rust',
  'toml', 'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  dependencies = { 'mason-org/mason.nvim' }, -- tree-sitter CLI comes from Mason
  config = function()
    local ts = require('nvim-treesitter')
    if vim.fn.executable('tree-sitter') == 1 then
      ts.install(ensure)
    end

    local available = {}
    for _, lang in ipairs(ts.get_available()) do
      available[lang] = true
    end

    local function start(buf, lang)
      if pcall(vim.treesitter.start, buf, lang) then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('config-treesitter', { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end
        if vim.treesitter.language.add(lang) then
          start(args.buf, lang)
        elseif available[lang] and vim.fn.executable('tree-sitter') == 1 then
          -- Install missing parsers on first use
          ts.install(lang):await(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              start(args.buf, lang)
            end
          end)
        end
      end,
    })
  end,
}
