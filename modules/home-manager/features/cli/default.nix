{inputs, ...}: {
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
    ./bash.nix
    ./bat.nix
    ./codex.nix
    ./direnv.nix
    ./fish
    ./fzf.nix
    ./git.nix
    ./ssh.nix
    ./nvim
    ./yazi.nix
    ./spicetify.nix
  ];
}
