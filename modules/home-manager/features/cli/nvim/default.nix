{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs;
      [
        # LazyVim dependencies
        git
        ripgrep
        fd
        fzf
        lazygit
        tree-sitter
        gcc
        gnumake
        wl-clipboard

        # LSP and formatters
        rust-analyzer
        rustfmt
        lua-language-server
        stylua
        nil
        nixfmt
        taplo

        # Typst
        typst
        websocat
        evince
      ]
      ++ [pkgs.unstablePkgs.tinymist];
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}