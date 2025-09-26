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

local function notify_error(msg)
  vim.notify("[mise-lspconfig] " .. msg, "error")
end

-- Register Neovim commands
--- @param mise_opts MLCMiseModule
--- @param lspconfig_opts MLCLspConfigModule
function M:register_commands(mise_opts, lspconfig_opts)
  vim.api.nvim_create_user_command(self.install.name, function(opts)
    if is_installing then
      vim.notify("[mise-lspconfig] Installation already in progress", "warn")
      return
    end

    local lsp_name = opts.args
    if not lsp_name or lsp_name == "" then
      notify_error("Please specify an LSP server name.")
      return
    end

    local tool = lspconfig_opts:get_required_cmd(lsp_name)
    if not tool then
      notify_error("Cannot find any tools required by " .. lsp_name)
      return
    end

    local tool_path = mise_opts:get_tool_path(tool)
    if tool_path then
      vim.notify("[mise-lspconfig] Tool " .. tool .. " is already installed", "warn")
      return
    end

    is_installing = true
    vim.notify("[mise-lspconfig] Installing " .. tool .. "...", "info")

    vim.schedule(function()
      local ok = mise_opts:install_tool(tool)
      is_installing = false
      if not ok then
        notify_error("Failed to install tool: " .. tool)
        return
      end

      local bin_path = mise_opts:get_tool_path(tool)
      if not bin_path then
        notify_error("Failed to get the path of the installed tool: " .. tool)
        return
      end

      local dir = vim.fn.fnamemodify(bin_path, ":h")

      local current_path = vim.env.PATH or ""
      if current_path == "" then
        vim.env.PATH = dir
      elseif not current_path:find(dir, 1, true) then
        vim.env.PATH = dir .. ":" .. current_path
      end

      vim.notify("[mise-lspconfig] " .. tool .. " installed and added to PATH", "info")
    end)
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
