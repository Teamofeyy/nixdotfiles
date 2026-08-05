{pkgs, ...}: {
  programs.obsidian = {
    enable = true;
    package = pkgs.obsidian;
  };
}