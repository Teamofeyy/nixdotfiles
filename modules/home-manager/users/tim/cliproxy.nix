{
  config,
  pkgs,
  ...
}: let
  baseUrl = "http://172.16.20.91:8317/v1";
  model = "gpt-6.1-sol";
  apiKeyPath = config.sops.secrets."cliproxy/api-key".path;
in {
  sops.secrets."cliproxy/api-key" = {};

  home.packages = [
    (pkgs.writeShellApplication {
      name = "codex-cliproxy";
      text = ''
        cliproxy_config=(
          -c 'model="${model}"'
          -c 'model_provider="cliproxy"'
          -c 'model_providers.cliproxy.name="Corporate CLIProxy"'
          -c 'model_providers.cliproxy.base_url="${baseUrl}"'
          -c 'model_providers.cliproxy.wire_api="responses"'
          -c 'model_providers.cliproxy.supports_websockets=false'
          -c 'model_providers.cliproxy.auth.command="${pkgs.coreutils}/bin/cat"'
          -c 'model_providers.cliproxy.auth.args=["${apiKeyPath}"]'
          -c 'model_providers.cliproxy.auth.refresh_interval_ms=0'
        )

        if [[ "''${1-}" == "doctor" ]]; then
          shift
          exec ${pkgs.codex}/bin/codex doctor "''${cliproxy_config[@]}" "$@"
        fi

        exec ${pkgs.codex}/bin/codex "''${cliproxy_config[@]}" "$@"
      '';
    })
  ];
}
