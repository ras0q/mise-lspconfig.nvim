---@class MLCModule
local M = {}

-- Configuration options for mise-lspconfig
---@class MLCOpts
---@field commands MLCCommandsModule
---@field mise MLCMiseModule
---@field lspconfig MLCLspConfigModule

--- @param opts MLCOpts
function M.setup(opts)
  ---@type MLCOpts
  local default_opts = {
    commands = require("mise-lspconfig.commands"),
    lspconfig = require("mise-lspconfig.lspconfig"),
    mise = require("mise-lspconfig.mise"),
  }
  M.opts = vim.tbl_deep_extend("force", default_opts, opts or {})

  if not M.opts.mise:check_available() then
    vim.notify(
      "[mise-lspconfig] mise executable not found. Please install mise or set the correct path in config.",
      "error"
    )
    return
  end

  M.opts.commands:register_commands(M.opts.mise, M.opts.lspconfig)
end

return M
