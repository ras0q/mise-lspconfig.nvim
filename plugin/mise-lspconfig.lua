if vim.g.loaded_mise_lspconfig then
  return
end
vim.g.loaded_mise_lspconfig = true

---@class MLCModule
local mlc = require("mise-lspconfig")
