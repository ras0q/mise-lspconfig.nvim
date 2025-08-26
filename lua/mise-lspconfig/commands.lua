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

-- Register Neovim commands
--- @param mise_opts MLCMiseModule
--- @param lspconfig_opts MLCLspConfigModule
function M.register_commands(mise_opts, lspconfig_opts)
  vim.api.nvim_create_user_command(M.install.name, function(opts)
    if is_installing then
      return
    end

    is_installing = true

    local lsp_name = opts.args
    if not lsp_name or lsp_name == "" then
      vim.notify("[mise-lspconfig] Please specify an LSP server name.", "error")
      is_installing = false
      return
    end

    local cmd = lspconfig_opts.get_required_cmd(lsp_name)
    if not cmd then
      vim.notify("[mise-lspconfig] Cannot find any tools required by " .. lsp_name, "error")
      is_installing = false
      return
    end
    -- TODO: convert to a correct tool name
    local tool = cmd

    if not mise_opts.is_tool_installed(tool) then
      mise_opts.install_tool(tool)
    end

    is_installing = false
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
