-- Git: codediff (changes panel + side-by-side diff, history, conflicts),
-- neogit (commit, push, pull, branches), gitsigns (hunks and blame in buffers).
local submode = require('config.submode')

local function gs()
  return require('gitsigns')
end

-- Next/previous hunk in a gitsigns buffer, or a codediff/vimdiff window
local function hunk(dir)
  return function()
    if vim.b.gitsigns_status_dict and not vim.wo.diff then
      gs().nav_hunk(dir > 0 and 'next' or 'prev')
    else
      vim.cmd('normal ' .. (dir > 0 and ']c' or '[c'))
    end
  end
end

local function neogit(popup)
  return function()
    require('neogit').open(popup and { popup } or {})
  end
end

local keys = {
  -- { chord, leader, action, desc }
  { '<A-0>', '<leader>gg', '<cmd>CodeDiff<CR>', 'Changes (stage + diff)' },
  { '<A-9>', '<leader>gl', '<cmd>CodeDiff history<CR>', 'Log' },
  { nil, '<leader>gL', '<cmd>CodeDiff history %<CR>', 'File history' },
  { nil, '<leader>gd', '<cmd>CodeDiff file HEAD<CR>', 'Diff file against HEAD' },
  { '<C-k>', '<leader>gc', neogit('commit'), 'Commit' },
  { '<C-S-k>', '<leader>gP', neogit('push'), 'Push' },
  { nil, '<leader>gp', neogit('pull'), 'Pull' },
  { nil, '<leader>gn', neogit(), 'Neogit status' },
  { nil, '<leader>gs', function() Snacks.picker.git_branches() end, 'Switch branch' },
  { nil, '<leader>gb', function() gs().blame_line({ full = true }) end, 'Blame line' },
  { nil, '<leader>gB', function() gs().blame() end, 'Blame file' },
}

local lazy_keys = {}
for _, k in ipairs(keys) do
  if k[1] then
    table.insert(lazy_keys, { k[1], k[3], desc = k[4] })
  end
  table.insert(lazy_keys, { k[2], k[3], desc = k[4] })
end

-- Hunk mode (<leader>gh): navigate, stage, reset, and preview hunks
table.insert(lazy_keys, {
  '<leader>gh',
  submode.create({
    name = 'HUNKS',
    keys = {
      { { 'n', 'j', '<Down>' }, hunk(1), 'next' },
      { { 'p', 'k', '<Up>' }, hunk(-1), 'prev' },
      { 's', function() gs().stage_hunk() end, 'stage/unstage' },
      { 'r', function() gs().reset_hunk() end, 'reset' },
      { 'v', function() gs().preview_hunk_inline() end, 'preview' },
    },
  }),
  desc = 'Hunk mode',
})

return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = lazy_keys,
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '\u{f0da}' },
        topdelete = { text = '\u{f0da}' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      on_attach = function(buf)
        local g = require('gitsigns')
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map('n', ']c', hunk(1), 'Next hunk')
        map('n', '[c', hunk(-1), 'Previous hunk')
        map('n', '<leader>hs', g.stage_hunk, 'Stage/unstage hunk')
        map('n', '<leader>hr', g.reset_hunk, 'Reset hunk')
        map('x', '<leader>hs', function() g.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage lines')
        map('x', '<leader>hr', function() g.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset lines')
        map('n', '<leader>hS', g.stage_buffer, 'Stage file')
        map('n', '<leader>hR', g.reset_buffer, 'Reset file')
        map('n', '<leader>hp', g.preview_hunk_inline, 'Preview hunk')
        map('n', '<leader>tb', g.toggle_current_line_blame, 'Toggle line blame')
        map({ 'o', 'x' }, 'ih', g.select_hunk, 'Hunk')
      end,
    },
  },
  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    build = ':CodeDiff install', -- fetch the diff library now, not on first use
    opts = {
      explorer = { view_mode = 'tree' },
      keymaps = {
        view = { quit = { 'q', '<Esc>' } },
        -- Keep <leader>c for code actions; conflicts live under <leader>g
        conflict = {
          accept_incoming = '<leader>gt',
          accept_current = '<leader>go',
          accept_both = '<leader>ga',
          discard = '<leader>gx',
          accept_all_incoming = '<leader>gT',
          accept_all_current = '<leader>gO',
          accept_all_both = '<leader>gA',
          discard_all = '<leader>gX',
        },
      },
    },
  },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'esmuellert/codediff.nvim', 'folke/snacks.nvim' },
    opts = {
      kind = 'tab',
      graph_style = 'unicode',
      diff_viewer = 'codediff',
      integrations = { codediff = true, snacks = true },
    },
  },
}
