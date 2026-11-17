# Neovim

LazyVim is supplied by the locked `lazyvim` flake input. Home Manager imports
its module through the existing `inputs` extraSpecialArgs. Plugins and parsers
come from Nix; Mason and runtime parser installation are disabled upstream.
`config/` is the only active user configuration. The old `nvim/` directory is
retained as an inactive archive because it contains a user edit.

Extras: Rust, Python, clangd, Nix, Typst, TOML, JSON, YAML, TypeScript, Markdown.
Servers: rust-analyzer (rustaceanvim), basedpyright + Ruff, clangd, nil,
Tinymist, Taplo, lua-language-server, html/cssls, vtsls, jsonls, yamlls, bashls.
Compilers, Cargo, Clippy and Python environments should come from project
`nix develop` / direnv environments. Open Neovim inside that environment.
Rustfmt and the other formatters are supplied by Nix.

Additional keys (Space is leader):

- `<leader>gV`: Git Graph; Enter opens `git show` in a terminal.
- `<leader>rr`: Rust runnables, with target selection.
- `<leader>rt`: `cargo test` at the Cargo workspace root.
- `<leader>rc`: `cargo clippy` at the Cargo workspace root.

Snacks terminals can be hidden with their standard terminal keys and reopened
by repeating the action. Existing LazyVim Git Log and Lazygit keys are preserved.
Diagnostics use virtual text, underline and severity signs; `<leader>cd` shows
the full message, `[d` / `]d` navigate, `<leader>xx` opens Trouble.
Typst: `<leader>cp` toggles live browser preview. Export with
`:!typst compile %` and open the resulting PDF with `:!evince %:r.pdf`.

Keymap self-check:

```sh
nvim --headless -u NONE -l modules/home-manager/features/cli/nvim/check.lua
```

Build the current host's Home Manager without replacing the repository's `result`:

```sh
nix build path:.#nixosConfigurations.teamofeymdr.config.home-manager.users.tim.home.activationPackage --out-link /tmp/lazyvim-home
```

Use `path:.` until new files have been added to Git. Apply through the normal
NixOS rebuild workflow using the flake host key `teamofeymdr` (the hostname is
`mdr-teamofey`). Previous Home Manager generations and Git provide rollback.

Validated on teamofeymdr (2026-11-17): Home Manager build and activation;
flake check for all hosts; clean startup including VeryLazy UI; LSP attachment
and intentional-error diagnostics for Rust, Python, C, Nix and Typst; Git Graph
render; Cargo run/test/clippy and Test/Clippy terminal output; formatter
executables; Typst Preview backend start/stop without downloads and PDF export.
Browser rendering, Evince display, interactive runnable selection, and LSP
attachment for the remaining languages were not visually verified.

Upstream compatibility fixes: explicitly include Blink Extra and its omitted
friendly-snippets dependency; use Blink's Lua matcher to avoid downloading a
native library; give Trouble symbols its explicit LSP source; provide websocat
to Typst Preview. No alternate UI components are installed.

`checkhealth` reports core LazyVim dependencies as available. Optional LuaRocks,
image rendering and other disabled Snacks features report warnings/errors in
headless checks; no additional tools were installed for these optional features.
Old live parser/query directories were preserved as
`~/.local/share/nvim/site/{parser,queries}.before-lazyvim-nix-20261117` before
activation. Keep these alongside the previous generation if rolling back.
