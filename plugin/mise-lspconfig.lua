if vim.g.loaded_mise_lspconfig then
  return
end
vim.g.loaded_mise_lspconfig = true

---@class MLCModule
local ml = require("mise-lspconfig")

vim.api.nvim_create_user_command("MiseInstallLsp", function(opts)
  local lsp_name = opts.args
  if not lsp_name or lsp_name == "" then
    vim.notify("[mise-lspconfig] Please specify an LSP server name.")
    return
  end

  local cmds = ml.opts.lspconfig.get_required_cmds(lsp_name)
  for _, cmd in ipairs(cmds) do
    -- TODO: convert to a correct tool name
    local tool = cmd

    if not ml.opts.mise.is_tool_installed(tool) then
      ml.opts.mise.install_tool(tool)
    end
  end
end, {
  nargs = 1,
  complete = function(arg)
    return vim
        .iter(vim.api.nvim_get_runtime_file(('lsp/%s*.lua'):format(arg), true))
        :map(function(path)
          local file_name = path:match('[^/]*.lua$')
          return file_name:sub(0, #file_name - 4)
        end)
        :totable()
  end,
  desc = "Install the LSP server tool using mise for a given LSP name"
})
