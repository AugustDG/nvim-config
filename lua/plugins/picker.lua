-- snacks.picker for files, search, symbols, and LSP results.
-- JetBrains chords, each with a leader equivalent.
local function pick(source, opts)
  return function()
    Snacks.picker[source](opts)
  end
end

local keys = {
  -- { chord, leader, action, desc }
  { nil, '<leader><leader>', pick('smart', { filter = { cwd = true } }), 'Search everywhere' },
  { '<C-e>', '<leader>fr', pick('recent', { filter = { cwd = true } }), 'Recent files' },
  { '<C-S-n>', '<leader>ff', pick('files'), 'Go to file' },
  { nil, '<leader>fa', pick('files', { hidden = true, ignored = true }), 'Go to file (all)' },
  { nil, '<leader>fb', pick('buffers'), 'Open buffers' },
  { nil, '<leader>fc', pick('files', { cwd = vim.fn.stdpath('config') }), 'Config files' },
  { '<C-S-f>', '<leader>sg', pick('grep'), 'Find in files' },
  { nil, '<leader>sw', pick('grep_word'), 'Find word in files', { 'n', 'x' } },
  { nil, '<leader>s/', pick('lines'), 'Search buffer lines' },
  { '<C-F12>', '<leader>ss', pick('lsp_symbols'), 'File structure' },
  { '<C-A-S-n>', '<leader>sS', pick('lsp_workspace_symbols'), 'Go to symbol' },
  { '<A-6>', '<leader>sd', pick('diagnostics'), 'Problems' },
  { '<C-S-a>', '<leader>sa', pick('commands'), 'Find action' },
  { nil, '<leader>sk', pick('keymaps'), 'Keymaps' },
  { nil, '<leader>sh', pick('help'), 'Help' },
  { nil, '<leader>sr', pick('resume'), 'Resume last search' },
  { nil, '<leader>s:', pick('command_history'), 'Command history' },
  { nil, '<leader>su', pick('undo'), 'Undo history' },
}

local lazy_keys = {}
for _, k in ipairs(keys) do
  local chord, leader, action, desc, mode = k[1], k[2], k[3], k[4], k[5] or 'n'
  if chord then
    table.insert(lazy_keys, { chord, action, mode = mode, desc = desc })
  end
  table.insert(lazy_keys, { leader, action, mode = mode, desc = desc })
end

return {
  'folke/snacks.nvim',
  lazy = false,
  priority = 900,
  keys = lazy_keys,
  opts = {
    picker = {
      layout = { preset = 'default' }, -- input on top, results below, preview right
      matcher = { frecency = true, cwd_bonus = true },
      formatters = { file = { filename_first = true } },
      win = {
        input = {
          keys = {
            ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
            ['<C-Up>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
            ['<C-Down>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
          },
        },
      },
    },
    input = { enabled = true }, -- nicer vim.ui.input (rename, prompts)
  },
}
