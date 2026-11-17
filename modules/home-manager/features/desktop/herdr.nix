{pkgs, ...}: {
  home.packages = with pkgs.unstablePkgs; [
    herdr-desktop
    herdr-core
  ];
}
