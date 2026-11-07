# nvim-config

Personal Neovim config (0.11+), managed with lazy.nvim.

## Layout

- `init.lua`: sets the leader and loads `lua/config/*`
- `lua/config/`: options, clipboard, keymaps, autocmds, lazy.nvim bootstrap
- `lua/plugins/`: one spec file per area, imported by lazy.nvim

## Notes

- The colorscheme follows the terminal background (OSC 11), including over SSH and inside tmux.
- The clipboard uses OSC 52 over SSH or when no native clipboard tool is installed.
- `:KeyTest` echoes the key chords nvim receives, for checking terminal and tmux passthrough.
