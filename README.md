# nvim-config
My personal goto Neovim config! 

Based off [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) :)

## Features

### 🛠️ Easy LSP and Formatting Setup with Mason

This config is designed to make adding new language servers and formatters as simple as possible:

#### Quick Start
- Press `<leader>m` to open Mason UI and install tools
- LSP servers, formatters, and linters are automatically configured
- Format-on-save is enabled by default (toggle with `:FormatToggle`)

#### Adding New Languages
1. Open `lua/plugins/mason.lua`  
2. Add your language server to the `servers` table
3. Restart neovim - Mason will auto-install the server
4. That's it! LSP features like go-to-definition, hover, etc. are ready

#### Useful Commands
- `:Mason` - Open Mason UI to manage LSP servers, formatters, linters
- `:Format` - Format current buffer manually
- `:FormatToggle` - Toggle auto-format on save
- `:FormatStatus` - Check if auto-formatting is enabled
- `:LspInfo` - Show attached LSP servers for current buffer
- `:MasonToolsUpdate` - Update all Mason tools

#### Pre-configured Languages
The following languages work out of the box:
- **Lua** (lua_ls + stylua formatter)
- **JavaScript/TypeScript** (tsserver + prettier formatter + eslint linter)  
- **Python** (pyright + black formatter + flake8 linter)
- **Go** (gopls + gofumpt formatter + golangci-lint)
- **Rust** (rust_analyzer + rustfmt)
- **C/C++** (clangd)
- **HTML/CSS** (html, cssls + prettier)
- **JSON/YAML** (jsonls, yamlls)

To enable more languages, just uncomment them in the `servers` table in `lua/plugins/mason.lua`.

## Installation

1. Install Neovim >= 0.9
2. Clone this config to your nvim config directory
3. Start nvim - plugins will auto-install
4. Enjoy coding! 🎉
