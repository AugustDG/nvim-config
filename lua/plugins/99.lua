return {
  'ThePrimeagen/99',
  config = function()
    local ai99 = require('99')

    ai99.setup({
      completion = {
        source = 'cmp',
      },
      md_files = {
        'AGENTS.md',
      },
      model = "gpt-5.3-codex",
    })

    vim.keymap.set('v', '<leader>9v', function()
      ai99.visual()
    end, { desc = '99 visual prompt' })

    vim.keymap.set('v', '<leader>9s', function()
      ai99.stop_all_requests()
    end, { desc = '99 stop requests' })

    vim.keymap.set('n', '<leader>99', function()
      vim.notify('99.search() not ready yet?', vim.log.levels.INFO)
    end, { desc = '99 search placeholder' })
  end,
}
