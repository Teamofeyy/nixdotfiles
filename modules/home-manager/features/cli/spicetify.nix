# For Home Manager: spicetify-nix.homeManagerModules.spicetify

{ pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
      catJamSynced
    ];
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
    ];
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };
}
