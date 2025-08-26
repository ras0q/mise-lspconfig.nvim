describe("mise-lspconfig.init", function()
  local M = require("mise-lspconfig.init")

  it("setup loads submodules", function()
    -- override mise.check_available to avoid system dependency
    local fake_mise = {
      check_available = function()
        return true
      end,
    }
    package.loaded["mise-lspconfig.mise"] = fake_mise
    package.loaded["mise-lspconfig.commands"] = require("mise-lspconfig.commands")
    package.loaded["mise-lspconfig.lspconfig"] = require("mise-lspconfig.lspconfig")

    M.setup({})

    assert.is_table(M.opts)
    assert.is_table(M.opts.commands)
    assert.is_table(M.opts.mise)
    assert.is_table(M.opts.lspconfig)
  end)
end)
