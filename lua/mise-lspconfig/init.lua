---@alias MLCOpts table

---@class MLCModule
---@field opts MLCOpts
local M = {
  opts = {
    mise = {},
    lspconfig = {},
  },
}

--- @param opts MLCOpts
function M.setup(opts)
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
