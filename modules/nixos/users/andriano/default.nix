{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    ./sops.nix
    ../../optional/l2tp.nix
  ];

  users.mutableUsers = true;
  users.users.andriano = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
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

    packages = [pkgs.home-manager];
  };
}
