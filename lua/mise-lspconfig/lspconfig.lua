local lspconfig = require("lspconfig")

---@class LSPConfigModule
local M = {}

---
--- Returns server info table for the given server, or nil.
function M.get_server_info(server_name)
  local server = lspconfig[server_name]
  if server and server.document_config and server.document_config.default_config then
    local default_config = server.document_config.default_config
    return {
      name = server_name,
      cmd = default_config.cmd,
    }
  end
  return nil
end

return M
