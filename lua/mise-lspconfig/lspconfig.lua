local lspconfig = require("lspconfig")

---@class MLCLspConfigModule
---@field server_mappings table Mapping of LSP server names to mise package names
local M = {
  server_mappings = {
    -- Example: markdown_oxide = "cargo:markdown-oxide"
  },
}

--- Returns a required cmd binary for a given LSP name (from lspconfig).
--- @param lsp_name string
--- @return string|nil cmd
function M:get_required_cmd(lsp_name)
  local server = lspconfig[lsp_name]
  if not (server and server.document_config and server.document_config.default_config) then
    return nil
  end
  local cmd = server.document_config.default_config.cmd
  if not cmd or not cmd[1] then
    return nil
  end
  return cmd[1]
end

--- @class MLCServerInfo
--- @field name string
--- @field cmd string

--- Returns server info table for the given server, or nil.
--- @param server_name string
--- @return MLCServerInfo | nil
function M:get_server_info(server_name)
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
