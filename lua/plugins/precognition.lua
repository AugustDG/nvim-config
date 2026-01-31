return {
  'tris203/precognition.nvim',
  opts = {},
  config = function(_, opts)
    local precognition = require('precognition')
    precognition.setup(opts)
    precognition.hide()

    vim.keymap.set('n', '<leader>p', precognition.peek, { desc = 'Toggles Precognition' })
  end,
}
