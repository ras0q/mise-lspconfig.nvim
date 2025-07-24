local lspconfig = require("lspconfig")

---@class MLCLspConfigModule
---@field server_mappings table Mapping of LSP server names to mise package names
local M = {
  server_mappings = {
    -- Example: markdown_oxide = "cargo:markdown-oxide"
  },
}

--- Returns a list of required cmd binaries for a given LSP name (from lspconfig).
--- @param lsp_name string
--- @return string[] cmds
function M.get_required_cmds(lsp_name)
  local cmds = lspconfig[lsp_name].document_config.default_config.cmd or {}
  return cmds
  -- local info = ml_lspconfig.get_server_info(lsp_name)
  -- if not info or not info.cmd then return {} end
  -- return info.cmd
end

--- @class MLCServerInfo
--- @field name string
--- @field cmd string

--- Returns server info table for the given server, or nil.
--- @param server_name string
--- @return MLCServerInfo | nil
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
