local lspconfig = vim.lsp.config

---@class MLCLspConfigModule
local M = {
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

return M
