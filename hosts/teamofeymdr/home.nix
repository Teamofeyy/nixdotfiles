{pkgs, ...}: {
  imports = [
    ../../modules/home-manager/users/tim
    ../../modules/home-manager/features/desktop/noctalia-university-schedule
  ];

  home.packages = with pkgs; [docker-compose];
}
