{
  lib,
  pkgs,
  ...
}: let
  blenderConfigVersion = lib.versions.majorMinor pkgs.blender.version;
in {
  home.packages = [pkgs.blender];

  xdg.configFile = {
    "blender/${blenderConfigVersion}/scripts/addons/blenderkit".source = "${pkgs.blendkit}/share/blender/scripts/addons/blenderkit";
    "blender/${blenderConfigVersion}/scripts/startup/enable-blendkit.py".text = ''
      import addon_utils

      addon_utils.enable("blenderkit", default_set=True, persistent=True)
    '';
  };
}
