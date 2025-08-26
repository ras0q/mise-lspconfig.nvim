local plenary_ok, _ = pcall(require, "plenary.job")

describe("mise-lspconfig.mise", function()
  local mise = require("mise-lspconfig.mise")

  it("check_available returns boolean", function()
    assert.is_boolean(mise.check_available())
  end)

  it("execute_command handles invalid command", function()
    assert.is_nil(mise.execute_command(nil, {}))
    assert.is_nil(mise.execute_command("", {}))
  end)

  if plenary_ok then
    it("is_tool_installed returns boolean", function()
      -- avoid executing real mise; stub execute_command
      local orig = mise.execute_command
      mise.execute_command = function() return nil end
      local res = mise.is_tool_installed("some-tool-that-does-not-exist-xyz")
      assert.is_boolean(res)
      mise.execute_command = orig
    end)
  end
end)
