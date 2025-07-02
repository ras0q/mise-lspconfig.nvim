local M = {}

--- Checks if mise is available on the system.
--- @param mise_cmd string mise command path
--- @return boolean available
function M.check_available(mise_cmd)
  local result = vim.fn.executable(mise_cmd)
  return result == 1
end

--- Execute a mise command and return the output (synchronously).
--- @param mise_cmd string mise command path
--- @param args string[] list of arguments (excluding mise_cmd)
--- @return string|nil output
function M.execute_command(mise_cmd, args)
  -- Ensure "mise_cmd" and all args are string and safe
  if type(mise_cmd) ~= 'string' or #mise_cmd == 0 then
    vim.notify("[mise-lspconfig] Invalid mise command")
    return nil
  end

  local safe_args = {}
  for _, arg in ipairs(args) do
    -- Only accept string arg and escape embedded quotes
    if type(arg) == 'string' then
      safe_args[#safe_args + 1] = arg:gsub('"', '\\"')
    end
  end


  local full_args = vim.iter({ mise_cmd, safe_args }):flatten():totable()
  vim.notify(("[mise-lspconfig] Executing `%s`"):format(table.concat(full_args, " ")))

  local result_tbl = nil
  local Job = require('plenary.job')
  local result, code = Job:new({
    command = mise_cmd,
    args = safe_args,
    on_exit = function(j)
      result_tbl = j:result()
    end
  }):sync()

  if result == nil or code ~= 0 then
    -- vim.notify("[mise-lspconfig] mise command failed: " .. table.concat(full_args, ' '))
    return nil
  end

  return table.concat(result_tbl or {}, "\n")
end

--- Install a tool using mise.
--- @param tool_name string package name
--- @param mise_cmd string mise command path
--- @param mise_args string[] additional mise arguments
--- @return boolean success
function M.install_tool(tool_name, mise_cmd, mise_args)
  vim.notify("[mise-lspconfig] Installing " .. tool_name .. " with mise...")

  local args = { "use" }
  for _, arg in ipairs(mise_args) do
    table.insert(args, arg)
  end
  table.insert(args, tool_name)

  local output = M.execute_command(mise_cmd, args)
  if output then
    vim.notify("[mise-lspconfig] " .. tool_name .. " installed successfully")
    return true
  else
    vim.notify("[mise-lspconfig] Failed to install " .. tool_name)
    return false
  end
end

---
--- Checks if a tool's binary is installed (either on $PATH or using mise's resolution).
--- @param tool_name string The tool's binary name
--- @param mise_cmd string mise command path
--- @param mise_args string[] Additional mise arguments (unused for now, future-proof)
--- @return boolean installed
function M.is_tool_installed(tool_name, mise_cmd, mise_args)
  local args = { "which", tool_name }
  for _, arg in ipairs(mise_args) do
    table.insert(args, arg)
  end

  local tool_path = M.execute_command(mise_cmd, args)
  if tool_path ~= nil then
    return true
  end

  if vim.fn.executable(tool_name) == 1 then
    vim.notify("[mise-lspconfig] Tool is installed, but not by mise.")
    return true
  end

  return false
end

return M
