{config, ...}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/tim"];
  };
}
