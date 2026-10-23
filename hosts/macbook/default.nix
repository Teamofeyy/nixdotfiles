{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix

    inputs.apple-silicon.nixosModules.apple-silicon-support
    ../../modules/nixos/common
    #../../modules/nixos/desktop
    #../../modules/nixos/physical.nix
    ../../modules/nixos/users/tim
    #../../modules/nixos/optional/systemd-boot.nix
    #../../modules/nixos/optional/docker.nix
    #../../modules/nixos/optional/throne.nix
  ];

  home-manager.users = {
    tim = import ./home.nix;
  };

  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;

  networking = {
    hostName = "macbook-teamofey";

    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  system.stateVersion = "25.05";
}
