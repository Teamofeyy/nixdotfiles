{pkgs, ...}: {
  imports = [../../modules/home-manager/users/tim];

  home.packages = with pkgs; [docker-compose];
}
