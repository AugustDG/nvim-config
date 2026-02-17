return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  lazy = false,
  config = function()
    vim.keymap.set('n', '<leader>f', function()
      require('fff').find_files()
    end, { desc = 'Current [F]iles' })

    vim.keymap.set('n', '<leader>sa', function()
      require('fff').find_in_git_root()
    end, { desc = '[S]earch Git files' })

    vim.keymap.set('n', '<leader>sg', function()
      require('fff').live_grep()
    end, { desc = '[S]earch by [G]rep' })
  end,
}
