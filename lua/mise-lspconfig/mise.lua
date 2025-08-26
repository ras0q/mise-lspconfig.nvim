---@class MLCMiseModule
---@field cmd string Path to mise executable
---@field args MiseConfigArgs
local M = {
  cmd = "mise",
  args = {
    global = {},
    use = {},
    which = {},
  },
}

---@class MiseConfigArgs
---@field global table
---@field use table
---@field which table

--- Checks if mise is available on the system.
--- @return boolean available
function M.check_available()
  local result = vim.fn.executable(M.cmd)
  return result == 1
end

--- Execute a mise command and return the output (synchronously).
--- @param mise_cmd string mise command path
--- @param args string[] list of arguments (excluding mise_cmd)
--- @return string|nil output
function M.execute_command(mise_cmd, args)
  -- Ensure "mise_cmd" and all args are string and safe
  if type(mise_cmd) ~= "string" or #mise_cmd == 0 then
    vim.notify("[mise-lspconfig] Invalid mise command")
    return nil
  end

  local safe_args = {}
  for _, arg in ipairs(args) do
    -- Only accept string arg and escape embedded quotes
    if type(arg) == "string" then
      safe_args[#safe_args + 1] = arg:gsub('"', '\\"')
    end
  end

  local full_args = vim.iter({ mise_cmd, safe_args }):flatten():totable()
  vim.notify(("[mise-lspconfig] Executing `%s`"):format(table.concat(full_args, " ")))

  local result_tbl = nil
  local Job = require("plenary.job")
  local result, code = Job:new({
    command = mise_cmd,
    args = safe_args,
    on_exit = function(j)
      result_tbl = j:result()
    end,
  }):sync()

  if result == nil or code ~= 0 then
    -- vim.notify("[mise-lspconfig] mise command failed: " .. table.concat(full_args, ' '))
    return nil
  end

  return table.concat(result_tbl or {}, "\n")
end

-- Install mason.nvim backend for mise
function M.install_mason_backend()
  local args = {
    "plugin",
    "install",
    "mason",
    "https://github.com/ras0q/mise-backend-mason",
  }

  local output = M.execute_command(M.cmd, args)
  if output then
    vim.notify("[mise-lspconfig] mason registry backend plugin installed successfully")
    return true
  else
    vim.notify("[mise-lspconfig] Failed to install mason registry backend plugin", "error")
    return false
  end
end

--- Install a tool using mise.
--- @param tool_name string package name
--- @return boolean success
function M.install_tool(tool_name)
  M.install_mason_backend()

  vim.notify("[mise-lspconfig] Installing " .. tool_name .. " with mise...")

  local args = { "use" }
  for _, arg in ipairs(M.args.global) do
    table.insert(args, arg)
  end
  for _, arg in ipairs(M.args.use) do
    table.insert(args, arg)
  end
  table.insert(args, "mason:" .. tool_name)

  local output = M.execute_command(M.cmd, args)
  if output then
    vim.notify("[mise-lspconfig] " .. tool_name .. " installed successfully")
    return true
  else
    vim.notify("[mise-lspconfig] Failed to install " .. tool_name, "error")
    return false
  end
end

--- Checks if a tool's binary is installed (either on $PATH or using mise's resolution).
--- @param tool_name string The tool's binary name
--- @return boolean installed
function M.is_tool_installed(tool_name)
  local args = { "which" }
  for _, arg in ipairs(M.args.global) do
    table.insert(args, arg)
  end
  for _, arg in ipairs(M.args.which) do
    table.insert(args, arg)
  end
  table.insert(args, "mason:" .. tool_name)

  local tool_path = M.execute_command(M.cmd, args)
  if tool_path ~= nil then
    return true
  end

  if vim.fn.executable(tool_name) == 1 then
    vim.notify("[mise-lspconfig] Tool is installed, but not by mise.", "warn")
    return true
  end

  return false
end

return M
