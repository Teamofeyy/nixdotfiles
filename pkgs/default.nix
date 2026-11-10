# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  blendkit = pkgs.callPackage ./blendkit {};
  herdr-app = pkgs.callPackage ./herdr-app {};
  # example = pkgs.callPackage ./example { };
}
