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
function M:check_available()
  local result = vim.fn.executable(self.cmd)
  return result == 1
end

--- Execute a mise command and return the output (synchronously).
--- @param args string[] list of arguments (excluding mise_cmd)
--- @return string|nil output
function M:execute_command(args)
  local full_args = vim.iter({ self.cmd, args }):flatten():totable()
  vim.notify(("[mise-lspconfig] Executing `%s`"):format(table.concat(full_args, " ")), "debug")

  -- Allow UI updates before long-running command
  vim.cmd("redraw")

  local result_tbl = nil
  local Job = require("plenary.job")
  local result, code = Job:new({
    command = self.cmd,
    args = args,
    on_exit = function(j)
      result_tbl = j:result()
    end,
  }):sync()

  if result == nil or code ~= 0 then
    return nil
  end

  return table.concat(result_tbl or {}, "\n")
end

-- Install mason.nvim backend for mise
function M:install_mason_backend()
  local args = {
    "plugin",
    "install",
    "mason",
    "https://github.com/ras0q/mise-backend-mason",
  }

  local output = self:execute_command(args)
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
function M:install_tool(tool_name)
  self:install_mason_backend()

  vim.notify("[mise-lspconfig] Installing " .. tool_name .. " with mise...")

  local args = { "use" }
  vim.list_extend(args, self.args.global)
  vim.list_extend(args, self.args.use)
  table.insert(args, "mason:" .. tool_name)

  local output = self:execute_command(args)
  if output then
    vim.notify("[mise-lspconfig] " .. tool_name .. " installed successfully")
    return true
  else
    vim.notify("[mise-lspconfig] Failed to install " .. tool_name, "error")
    return false
  end
end

--- Get the full path to a tool's binary using mise which (returns first line).
--- @param tool_name string The tool's package name
--- @return string|nil path The resolved binary path or nil if not found
function M:get_tool_path(tool_name)
  local args = { "which" }
  vim.list_extend(args, self.args.which)
  table.insert(args, tool_name)

  local tool_path = self:execute_command(args)
  if not tool_path or tool_path:match("^%s*$") then
    return nil
  end

  -- Return the first non-empty line, trimmed
  local first_line = tool_path:match("([^\n]+)")
  return first_line and first_line:match("^%s*(.-)%s*$")
end

return M
