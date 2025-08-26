# mise-lspconfig.nvim

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/ras0q/mise-lspconfig.nvim/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

Install language servers with mise!

## Installation

```lua
-- lazy.nvim
{
  "ras0q/mise-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {},
  keys = {
    { "gd", "<cmd>lua vim.lsp.buf.definition()  <CR>", "Go to definition" },
    { "gD", "<cmd>lua vim.lsp.buf.declaration() <CR>", "Go to declaration" },
  },
}
```

## Usage

```txt
:MiseLspInstall lua_ls
```

## Configuration

🚧 See [init.lua](./lua/mise-lspconfig/init.lua)

