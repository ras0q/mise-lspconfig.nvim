describe("mise-lspconfig.commands", function()
  local cmds = require("mise-lspconfig.commands")

  it("has default install.name", function()
    assert.is_table(cmds)
    assert.is_table(cmds.install)
    assert.are.equal("MiseLspInstall", cmds.install.name)
  end)
end)
