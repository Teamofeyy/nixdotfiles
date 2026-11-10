{pkgs, ...}: {
  imports = [
    ../../modules/home-manager/users/tim
    ../../modules/home-manager/features/desktop/noctalia-university-schedule
    ../../modules/home-manager/features/desktop/session-restore.nix
  ];

  home.packages = with pkgs; [docker-compose];
}
