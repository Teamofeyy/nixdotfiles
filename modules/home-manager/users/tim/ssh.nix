{config, ...}: {
  programs.ssh.settings = {
    "gitlab.internal.madrigal.ru" = {
      user = "git";
      identityFile = config.sops.secrets."ssh/gitlab".path;
    };

    "github.com" = {
      user = "git";
      identityFile = config.sops.secrets."ssh/github".path;
    };
  };

  sops.secrets = {
    "ssh/github".mode = "0400";
    "ssh/gitlab".mode = "0400";
  };
}
