return {
  {
    "saghen/blink.cmp",
    -- shortcut: pinned upstream package has no native library, use Lua until upstream builds it.
    opts = { fuzzy = { implementation = "lua" } },
  },
  {
    "folke/trouble.nvim",
    opts = { modes = { symbols = { source = "lsp.document_symbols" } } },
  },
  {
    "chomosuke/typst-preview.nvim",
    opts = { dependencies_bin = { tinymist = "tinymist", websocat = "websocat" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = { spacing = 2, prefix = "●" },
        virtual_lines = false,
        underline = true,
        signs = true,
        severity_sort = true,
        update_in_insert = true,
      },
      servers = { html = {}, cssls = {}, bashls = {} },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    opts = { server = { default_settings = {
      ["rust-analyzer"] = { check = { command = "clippy" } },
    } } },
  },
}
