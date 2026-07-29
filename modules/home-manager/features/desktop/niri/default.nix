{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.niri = {
    package = pkgs.niri;
    settings =
      import ./settings.nix {
        inherit pkgs lib;
        noctaliaBin = lib.getExe config.programs.noctalia.package;
      }
      // import ./keybinds.nix {
        noctaliaBin = lib.getExe config.programs.noctalia.package;
      }
      // import ./windowrules.nix;
  };

  home.packages = with pkgs; [
    brightnessctl
    wireplumber
    kdePackages.dolphin
    playerctl
  ];
}
