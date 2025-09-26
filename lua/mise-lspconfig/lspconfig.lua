local lspconfig = vim.lsp.config

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
  if not server or not server.cmd then
    return nil
  end
  if type(server.cmd) == "function" then
    vim.notify("[mise-lspconfig] server.cmd is a function (unsupported)", "warn")
    return nil
  end
  if #server.cmd < 1 then
    return nil
  end

  return server.cmd[1]
end

--- @class MLCServerInfo
--- @field name string
--- @field cmd string

--- Returns server info table for the given server, or nil.
--- @param server_name string
--- @return MLCServerInfo | nil
function M:get_server_info(server_name)
  local server = lspconfig[server_name]
  if not (server and server.cmd) then
    return nil
  end

  return {
    name = server_name,
    cmd = server.cmd,
  }
end

return M
