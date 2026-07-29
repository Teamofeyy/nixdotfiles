{inputs, ...}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age = {
      sshKeyPaths = ["/etc/ssh"];
      keyFile = "/var/lib/sops-nix/keys.txt";

      generateKey = true;
    };
  };
}
