local precognition = require("precognition")

vim.keymap.set('n', '<leader>p', precognition.peek, { desc = 'Toggles Precognition' })

precognition.setup({})
precognition.hide()

return {}
