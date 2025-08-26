describe("mise-lspconfig.lspconfig", function()
  local lsp = require("mise-lspconfig.lspconfig")

  it("get_required_cmd returns nil for unknown server", function()
    assert.is_nil(lsp.get_required_cmd("nonexistent_server_xyz"))
  end)

  it("get_server_info returns nil for unknown server", function()
    assert.is_nil(lsp.get_server_info("nonexistent_server_xyz"))
  end)
end)
