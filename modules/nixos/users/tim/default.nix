{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  userGroups = ifTheyExist [
    "audio"
    "docker"
    "git"
    "i2c"
    "input"
    "libvirtd"
    "wpa_supplicant"
    "plugdev"
    "podman"
    "video"
    "wheel"
    "wireshark"
    "networkmanager"
    "render"
  ];
in {
  imports = [
    ./sops.nix
    #../../optional/l2tp.nix
  ];

  users.mutableUsers = true;
  users.users.tim = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = userGroups;

    packages = [pkgs.home-manager];
  };

  users.users.teamofey = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = userGroups;

    packages = [pkgs.home-manager];
  };
}
