---@alias MLCOpts table

-- Refer to the respective subdirectories for the default settings.
---@class MLCModule
---@field opts MLCOpts
local M = {
  opts = {
    commands = {},
    mise = {},
    lspconfig = {},
  },
}

--- @param opts MLCOpts
function M.setup(opts)
  ---@type MLCCommandsModule
  M.opts.commands = require("mise-lspconfig.commands")

  ---@type MLCMiseModule
  M.opts.mise = require("mise-lspconfig.mise")

  ---@type MLCLspConfigModule
  M.opts.lspconfig = require("mise-lspconfig.lspconfig")

  opts = opts or {}
  M.opts = vim.tbl_deep_extend("force", M.opts, opts)

  if not M.opts.mise.check_available() then
    vim.notify("[mise-lspconfig] mise executable not found. Please install mise or set the correct path in config.")
    return
  end
end

return M
