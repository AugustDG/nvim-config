-- Project-wide editing: replace in path (grug-far), editable quickfix
-- (quicker), and multiple cursors (multicursor).
local submode = require('config.submode')

local function qf_step(dir)
  return function()
    local ok = pcall(vim.cmd, dir > 0 and 'cnext' or 'cprevious')
    if not ok then
      pcall(vim.cmd, dir > 0 and 'cfirst' or 'clast') -- wrap around
    end
  end
end

return {
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    opts = { headerMaxWidth = 80 },
    keys = {
      { '<C-S-r>', function() require('grug-far').open() end, desc = 'Replace in files' },
      { '<leader>sR', function() require('grug-far').open() end, desc = 'Replace in files' },
      {
        '<leader>sR',
        function() require('grug-far').with_visual_selection() end,
        mode = 'x',
        desc = 'Replace selection in files',
      },
      {
        '<leader>sW',
        function() require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } }) end,
        desc = 'Replace word in files',
      },
      {
        '<leader>sF',
        function() require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } }) end,
        desc = 'Replace in current file',
      },
    },
  },
  {
    -- Edit lines in the quickfix list and :w to apply them to their files.
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    opts = {
      keys = {
        { '>', function() require('quicker').expand({ before = 2, after = 2, add_to_existing = true }) end, desc = 'Expand context' },
        { '<', function() require('quicker').collapse() end, desc = 'Collapse context' },
      },
    },
    keys = {
      { '<C-A-Down>', qf_step(1), desc = 'Next quickfix item' },
      { '<C-A-Up>', qf_step(-1), desc = 'Previous quickfix item' },
      { '<leader>xq', function() require('quicker').toggle({ focus = true }) end, desc = 'Toggle quickfix' },
      { '<leader>xl', function() require('quicker').toggle({ loclist = true, focus = true }) end, desc = 'Toggle loclist' },
      {
        '<leader>q',
        submode.create({
          name = 'QUICKFIX',
          keys = {
            { { 'n', 'j', '<Down>' }, qf_step(1), 'next' },
            { { 'p', 'k', '<Up>' }, qf_step(-1), 'prev' },
            { 'o', function() require('quicker').toggle({ focus = false }) end, 'toggle list' },
          },
        }),
        desc = 'Quickfix mode',
      },
    },
  },
  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
    event = 'VeryLazy',
    config = function()
      local mc = require('multicursor-nvim')
      mc.setup()
      local map = vim.keymap.set

      -- JetBrains: Alt-J add next occurrence, Ctrl-Alt-Shift-J all occurrences
      map({ 'n', 'x' }, '<A-j>', function() mc.matchAddCursor(1) end, { desc = 'Add cursor at next match' })
      map({ 'n', 'x' }, '<C-A-S-j>', mc.matchAllAddCursors, { desc = 'Add cursors at all matches' })
      map('n', '<C-LeftMouse>', mc.handleMouse)
      map('n', '<C-LeftDrag>', mc.handleMouseDrag)
      map('n', '<C-LeftRelease>', mc.handleMouseRelease)

      -- Cursor mode (<leader>n): keep adding/skipping cursors, then edit.
      map({ 'n', 'x' }, '<leader>n', submode.create({
        name = 'CURSORS',
        visual = 'keep',
        esc = 'pass', -- Esc cancels the cursors, as in Zed
        keys = {
          { 'n', function() mc.matchAddCursor(1) end, 'next' },
          { 'N', function() mc.matchAddCursor(-1) end, 'prev' },
          { 's', function() mc.matchSkipCursor(1) end, 'skip' },
          { 'S', function() mc.matchSkipCursor(-1) end, 'skip prev' },
          { { 'j', '<Down>' }, function() mc.lineAddCursor(1) end, 'below' },
          { { 'k', '<Up>' }, function() mc.lineAddCursor(-1) end, 'above' },
          { 'a', mc.matchAllAddCursors, 'all' },
          { 'x', mc.deleteCursor, 'del' },
        },
      }), { desc = 'Cursor mode' })
      -- ga{motion}: a cursor on each line (e.g. gaip for a paragraph)
      map({ 'n', 'x' }, 'ga', mc.addCursorOperator, { desc = 'Add cursors over motion' })
      map('x', 'M', mc.matchCursors, { desc = 'Cursors at regex matches in selection' })
      map('x', 'S', mc.splitCursors, { desc = 'Split selection by regex' })
      map('n', '<leader>gv', mc.restoreCursors, { desc = 'Restore cursors' })

      -- Only while several cursors exist
      mc.addKeymapLayer(function(layer)
        layer({ 'n', 'x' }, '<Left>', mc.prevCursor)
        layer({ 'n', 'x' }, '<Right>', mc.nextCursor)
      end)

      -- Esc: clear cursors (or re-enable disabled ones), else clear search
      -- highlight. Global rather than in the layer so submodes can override it.
      map('n', '<Esc>', function()
        if mc.hasCursors() then
          if mc.cursorsEnabled() then
            mc.clearCursors()
          else
            mc.enableCursors()
          end
        else
          vim.cmd.nohlsearch()
        end
      end, { desc = 'Clear cursors / search highlight' })

      local hl = vim.api.nvim_set_hl
      hl(0, 'MultiCursorCursor', { reverse = true })
      hl(0, 'MultiCursorVisual', { link = 'Visual' })
      hl(0, 'MultiCursorSign', { link = 'SignColumn' })
      hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
      hl(0, 'MultiCursorDisabledCursor', { reverse = true })
      hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
    end,
  },
}
