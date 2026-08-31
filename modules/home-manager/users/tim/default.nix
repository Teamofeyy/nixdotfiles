{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  harnessRoot = "${config.home.homeDirectory}/harness-test";
  hasOpenRouterSecret =
    builtins.length (builtins.split "openrouter-api-key:" (builtins.readFile ./secrets.yaml)) > 1;
  openrouterSecretsPath = "${config.home.homeDirectory}/nixdotfiles/modules/home-manager/users/tim/secrets.yaml";
  openrouterSecretSetup =
    if hasOpenRouterSecret
    then ''
      env_file="${config.sops.templates."harness-test-openrouter.env".path}"
      if [ ! -r "$env_file" ]; then
        printf 'ERROR: OpenRouter environment file is not readable: %s\n' "$env_file" >&2
        exit 1
      fi

      OPENROUTER_API_KEY="$(
        while IFS='=' read -r key value; do
          if [ "$key" = "OPENROUTER_API_KEY" ]; then
            printf '%s' "$value"
            break
          fi
        done < "$env_file"
      )"
      export OPENROUTER_API_KEY

      if [ -z "''${OPENROUTER_API_KEY:-}" ]; then
        printf 'ERROR: OPENROUTER_API_KEY is empty in %s\n' "$env_file" >&2
        exit 1
      fi
    ''
    else ''
      printf 'ERROR: missing sops key openrouter-api-key in %s\n' "${openrouterSecretsPath}" >&2
      printf 'Add it with: sops set modules/home-manager/users/tim/secrets.yaml '"'"'["openrouter-api-key"]'"'"' '"'"'"sk-or-v1-..."'"'"'\n' >&2
      exit 1
    '';

  harnessCommand = name: flakeApp:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [
        coreutils
        nix
      ];
      text = ''
        harness_root="''${HARNESS_TEST_ROOT:-${harnessRoot}}"
        if [ ! -d "$harness_root/.pi" ]; then
          printf 'ERROR: harness-test checkout not found at %s\n' "$harness_root" >&2
          printf 'Set HARNESS_TEST_ROOT to the checkout path and retry.\n' >&2
          exit 1
        fi

        cd "$harness_root"
        exec nix run ".#${flakeApp}" -- "$@"
      '';
    };

  harnessOpenRouterCommand = pkgs.writeShellApplication {
    name = "harness-test-pi-ox-alpha";
    runtimeInputs = with pkgs; [
      coreutils
      nix
    ];
    text =
      if hasOpenRouterSecret
      then ''
        ${openrouterSecretSetup}

        harness_root="''${HARNESS_TEST_ROOT:-${harnessRoot}}"
        if [ ! -d "$harness_root/.pi" ]; then
          printf 'ERROR: harness-test checkout not found at %s\n' "$harness_root" >&2
          printf 'Set HARNESS_TEST_ROOT to the checkout path and retry.\n' >&2
          exit 1
        fi

        cd "$harness_root"
        exec nix run ".#pi-openrouter-ox-alpha" -- "$@"
      ''
      else ''
        ${openrouterSecretSetup}
      '';
  };
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../../shared
    ../../features/cli
    ../../features/desktop
    ./sops.nix
    ./git.nix
    ./jj.nix
    #./opencode.nix
    ./ssh.nix
  ];

  home.packages = [
    (harnessCommand "harness-test-pi-install" "pi-install")
    (harnessCommand "harness-test-pi" "pi")
    (harnessCommand "harness-test-pi-doctor" "pi-doctor")
    harnessOpenRouterCommand
  ];

  home.shellAliases.rebuild = "nixos-rebuild switch --flake ~/nixos#$(hostname) --sudo";

  sops.templates = lib.mkIf hasOpenRouterSecret {
    "harness-test-openrouter.env" = {
      content = ''
        OPENROUTER_API_KEY=${config.sops.placeholder.openrouter-api-key}
      '';
    };
  };

  sops.secrets = lib.mkIf hasOpenRouterSecret {
    openrouter-api-key = {};
  };
}
