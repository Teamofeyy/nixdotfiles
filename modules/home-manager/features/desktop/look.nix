 {
    inputs,
    pkgs,
    ...
  }: {
    home.packages = [
      inputs.look.packages.${pkgs.system}.default
    ];
  }