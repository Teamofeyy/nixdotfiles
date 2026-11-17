{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.lazyvim.homeManagerModules.default];

  programs.neovim = {
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.lazyvim = {
    enable = true;
    extras.coding.blink.enable = true;
    configFiles = ./config;
    extras.lang =
      lib.genAttrs [
        "rust"
        "python"
        "clangd"
        "nix"
        "typst"
        "toml"
        "json"
        "yaml"
        "typescript"
        "markdown"
      ] (_: {
        enable = true;
        # Tools are explicit below; runtimes and compilers come from devShells.
        installDependencies = false;
        installRuntimeDependencies = false;
      });
    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [css];
    extraPackages = with pkgs; [
      rust-analyzer
      rustfmt
      basedpyright
      ruff
      clang-tools
      nil
      nixfmt
      statix
      tinymist
      typst
      typstyle
      websocat
      evince
      taplo
      lua-language-server
      stylua
      vscode-langservers-extracted
      vtsls
      nodejs
      prettierd
      prettier
      yaml-language-server
      bash-language-server
      shfmt
      shellcheck
      markdownlint-cli2
      wl-clipboard
    ];
    # Upstream metadata omits this transitive Blink dependency.
    plugins.snippets = ''
      return {{ "rafamadriz/friendly-snippets", dir = "${pkgs.vimPlugins.friendly-snippets}" }}
    '';
    plugins.gitgraph = ''
      return {
        {
          "isakbm/gitgraph.nvim",
          dir = "${pkgs.vimUtils.buildVimPlugin {
        pname = "gitgraph.nvim";
        version = inputs.gitgraph.shortRev or "locked";
        src = inputs.gitgraph;
      }}",
          keys = {{ "<leader>gV", function()
            require("gitgraph").draw({}, { all = true, max_count = 1000 })
          end, desc = "Git Graph" }},
          opts = { hooks = {
            on_select_commit = function(commit)
              Snacks.terminal({ "git", "show", commit.hash }, { cwd = LazyVim.root.git() })
            end,
          } },
        },
      }
    '';
  };
}
