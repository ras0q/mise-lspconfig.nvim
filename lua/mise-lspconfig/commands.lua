---@class MLCCommandsModule
---@field install MLCCommandsInstallArgs
local M = {
  install = {
    -- To prevent conflicts with mason.nvim, the default is set to `MiseLspInstall`.
    -- You may change it to “LspInstall” if you prefer.
    name = "MiseLspInstall",
  },
}

---@class MLCCommandsInstallArgs
---@field name string
