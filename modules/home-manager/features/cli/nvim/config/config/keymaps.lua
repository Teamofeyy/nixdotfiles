local function cargo(command)
  vim.cmd("wall")
  local manifest = vim.fs.find("Cargo.toml", { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1]
  if not manifest then
    return vim.notify("Cargo.toml not found", vim.log.levels.ERROR)
  end
  local result = vim.system({ "cargo", "locate-project", "--workspace", "--message-format", "plain", "--manifest-path", manifest }, { text = true }):wait()
  if result.code ~= 0 then
    return vim.notify(result.stderr, vim.log.levels.ERROR)
  end
  Snacks.terminal({ "cargo", command }, { cwd = vim.fs.dirname(vim.trim(result.stdout)) })
end
vim.keymap.set("n", "<leader>rr", "<cmd>RustLsp runnables<cr>", { desc = "Rust Run (select target)" })
vim.keymap.set("n", "<leader>rt", function() cargo("test") end, { desc = "Rust Test workspace" })
vim.keymap.set("n", "<leader>rc", function() cargo("clippy") end, { desc = "Rust Clippy workspace" })
