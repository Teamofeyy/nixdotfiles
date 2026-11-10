{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.config
    inputs.zen-browser.homeModules.default
    inputs.noctalia.homeModules.default
    ./font.nix
    ./herdr.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./alacritty.nix
    ./niri
    ./zen-browser.nix
    ./vicinae.nix
    ./noctalia.nix
    ./zed.nix
    ./telegram.nix
    ./tmux.nix
    ./obsidian.nix
    ./anki.nix
    ./blender.nix
    ./readest.nix
    #./opencodecl
  ];
  xdg = {
    dataFile."applications/yazi.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Yazi
      GenericName=File Manager
      Exec=alacritty -e yazi %f
      Terminal=false
      MimeType=inode/directory;
      Categories=System;FileTools;FileManager;
      NoDisplay=true
    '';

    mimeApps = {
      enable = true;

      defaultApplications = {
        "inode/directory" = ["yazi.desktop"];
      };

      associations.added = {
        "inode/directory" = ["yazi.desktop"];
      };
    };
    mime.enable = true;

    terminal-exec = {
      enable = true;

      settings = {
        default = [
          "alacritty.desktop"
        ];
      };
    };

    portal = {
      xdgOpenUsePortal = true;
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gnome]; # or whatever you use
      config = {
        niri = {
          default = [
            "gnome"
            "gtk"
          ];
        };
        common = {
          default = ["gtk"];
        };
      };
    };
  };

  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
    typst
  ];
}
