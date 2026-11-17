-- Run with: nvim --headless -l check.lua
local root = vim.fn.fnamemodify(arg[0], ":p:h")
local maps = {}
local commands = {}
local terminal
vim.keymap.set = function(_, key, action) maps[key] = action end
vim.cmd = function() end
vim.notify = function(message) error(message) end
vim.system = function(command)
  commands = command
  return { wait = function() return { code = 0, stdout = "/tmp/workspace/Cargo.toml\n" } end }
end
vim.fs.find = function() return { "/tmp/workspace/member/Cargo.toml" } end
Snacks = { terminal = function(command, opts) terminal = { command, opts } end }
dofile(root .. "/config/config/keymaps.lua")
for key, command in pairs({ ["<leader>rt"] = "test", ["<leader>rc"] = "clippy" }) do
  maps[key]()
  assert(commands[3] == "--workspace")
  assert(terminal[1][2] == command)
  assert(terminal[2].cwd == "/tmp/workspace")
end
assert(maps["<leader>rr"] == "<cmd>RustLsp runnables<cr>")
print("Cargo keymaps: OK")
