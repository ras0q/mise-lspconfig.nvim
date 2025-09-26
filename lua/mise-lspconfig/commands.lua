---@class MLCCommandsModule
---@field install MLCCommandsInstallArgs
local M = {
  install = {
    -- To prevent conflicts with mason.nvim, the default is set to `MiseLspInstall`.
    -- You may change it to “LspInstall” if you prefer.
    name = "MiseLspInstall",
  },
}

---@class MLCCommandsInstallArgs
---@field name string

local is_installing = false

-- TODO: define globally
local function notify_error(msg)
  vim.schedule(function()
    vim.notify("[mise-lspconfig] " .. msg, "error")
  end)
end

-- Register Neovim commands
--- @param mise_opts MLCMiseModule
--- @param lspconfig_opts MLCLspConfigModule
function M:register_commands(mise_opts, lspconfig_opts)
  vim.api.nvim_create_user_command(self.install.name, function(opts)
    if is_installing then
      return
    end

    local lsp_name = opts.args
    if not lsp_name or lsp_name == "" then
      notify_error("Please specify an LSP server name.")
      return
    end

    local cmd = lspconfig_opts:get_required_cmd(lsp_name)
    if not cmd then
      notify_error("Cannot find any tools required by " .. lsp_name)
      return
    end

    -- TODO: convert to a correct tool name
    local tool = cmd

    if mise_opts:is_tool_installed(tool) then
      return
    end

    vim.defer_fn(function()
      vim.schedule(function()
        is_installing = true
      end)
      vim.notify("[mise-lspconfig] Installing " .. tool .. "...", "info")

      local ok = mise_opts:install_tool(tool)
      vim.schedule(function()
        is_installing = false
      end)
      if not ok then
        notify_error("Failed to install tool: " .. tool)
        return
      end

      local bin_path = mise_opts:get_path(tool)
      if not bin_path then
        notify_error("Failed to get the path of the installed tool: " .. tool)
        return
      end

      local dir = bin_path:match("^(.*/)")
      if not dir or dir == "" then
        notify_error("Failed to extract directory from path: " .. bin_path)
        return
      end

      local current_path = vim.env.PATH or ""
      vim.schedule(function()
        if current_path == "" then
          vim.env.PATH = dir
          return
        end
        if not current_path:find(dir, 1, true) then
          vim.env.PATH = dir .. ":" .. current_path
        end
      end)
    end, 60000)
  end, {
    nargs = 1,
    complete = function(arg)
      return vim
          .iter(vim.api.nvim_get_runtime_file(("lsp/%s*.lua"):format(arg), true))
          :map(function(path)
            local file_name = path:match("[^/]*.lua$")
            return file_name:sub(0, #file_name - 4)
          end)
          :totable()
    end,
    desc = "Install the LSP server tool using mise for a given LSP name",
  })
end

return M
