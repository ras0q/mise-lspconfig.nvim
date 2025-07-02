---@class Config
---@field mise_cmd string Path to mise executable
---@field mise_args table Additional mise arguments
---@field server_mappings table Mapping of LSP server names to mise package names
local config = {
  mise_cmd = "mise",
  mise_args = { "-g" },
  server_mappings = {
    -- Example: markdown_oxide = "cargo:markdown-oxide"
  }
}

local ml_mise = require("mise-lspconfig.mise")
local lspconfig = require("lspconfig")
local ml_lspconfig = require("mise-lspconfig.lspconfig")

local M = {}

M.config = config

function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  if not ml_mise.check_available(M.config.mise_cmd) then
    vim.notify("[mise-lspconfig] mise executable not found. Please install mise or set the correct path in config.")
    return
  end
end

function M.get_available_language_servers()
  return ml_lspconfig.get_available_language_servers()
end

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

--- Returns true if the given tool's binary is installed (via mise or on $PATH).
--- @param tool string (tool binary or package name)
--- @return boolean
function M.is_tool_installed(tool)
  return ml_mise.is_tool_installed(tool, M.config.mise_cmd, M.config.mise_args)
end

--- Installs the given tool via mise.
--- @param tool string (tool name)
function M.install_tool(tool)
  ml_mise.install_tool(tool, M.config.mise_cmd, M.config.mise_args)
end

return M
