{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Upstream always restores on startup and has no one-shot save command.
  nirinit = inputs.nirinit.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./nirinit-optional.patch];
  });
  nirinitConfig = (pkgs.formats.toml {}).generate "nirinit-config.toml" {};

  saveBeforeExit = pkgs.writeShellApplication {
    name = "session-restore-save";
    runtimeInputs = [pkgs.systemd];
    text = ''
      umask 077
      systemctl --user stop nirinit.service
      if [[ -f "''${XDG_STATE_HOME:-$HOME/.local/state}/nirinit/restore-next-session" ]]; then
        exec ${lib.getExe nirinit} --config ${nirinitConfig} --save-only
      fi
    '';
  };

  toggleRestore = pkgs.writeShellApplication {
    name = "session-restore-toggle";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.libnotify
    ];
    text = ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/nirinit"
      marker="$state_dir/restore-next-session"

      umask 077
      mkdir -p "$state_dir"

      if [[ -e "$marker" ]]; then
        rm -f -- "$marker"
        notify-send -a Noctalia -i window-close-symbolic \
          "Восстановление сессии отключено" \
          "Следующий вход начнётся с чистого рабочего стола." || true
      else
        touch "$marker"
        notify-send -a Noctalia -i view-refresh-symbolic \
          "Восстановление сессии включено" \
          "Окна будут восстановлены один раз при следующем входе." || true
      fi
    '';
  };

  startNirinit = pkgs.writeShellApplication {
    name = "nirinit-optional-restore";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/nirinit"
      marker="$state_dir/restore-next-session"
      prepared="''${RUNTIME_DIRECTORY:?}/prepared"

      umask 077
      mkdir -p "$state_dir"
      restore_args=(--no-restore)

      if [[ ! -e "$prepared" || "$(<"$prepared")" != "''${NIRI_SOCKET:?}" ]]; then
        if [[ -e "$marker" ]]; then
          rm -f -- "$marker"
          restore_args=()
        fi
        printf '%s' "$NIRI_SOCKET" > "$prepared"
      fi

      exec ${lib.getExe nirinit} --config ${nirinitConfig} --save-interval 60 "''${restore_args[@]}"
    '';
  };

  noctalia = lib.getExe config.programs.noctalia.package;
  openSessionPanel = {
    repeat = false;
    action.spawn = [
      noctalia
      "msg"
      "panel-toggle"
      "session"
    ];
  };
in {
  home.packages = [toggleRestore];

  programs.noctalia.settings.hooks = {
    logging_out = lib.getExe saveBeforeExit;
    rebooting = lib.getExe saveBeforeExit;
    shutting_down = lib.getExe saveBeforeExit;
  };

  systemd.user.services.nirinit = {
    Unit = {
      Description = "Save and optionally restore the Niri session";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
      ConditionEnvironment = "NIRI_SOCKET";
    };
    Service = {
      ExecStart = lib.getExe startNirinit;
      Restart = "on-failure";
      RestartSec = 2;
      RuntimeDirectory = "nirinit";
      RuntimeDirectoryPreserve = "yes";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  programs.noctalia.settings.shell.session = {
    grid = true;
    grid_columns = 3;
    actions = [
      {
        action = "lock";
        shortcut = "1";
      }
      {
        action = "logout";
        shortcut = "2";
      }
      {
        action = "lock_and_suspend";
        shortcut = "3";
      }
      {
        action = "reboot";
        shortcut = "4";
      }
      {
        action = "shutdown";
        shortcut = "5";
        variant = "destructive";
      }
      {
        action = "command";
        command = lib.getExe toggleRestore;
        label = "Восстановить окна";
        glyph = "history";
        shortcut = "6";
        variant = "outline";
      }
    ];
  };

  programs.niri.settings.binds = {
    "Mod+Shift+E" = lib.mkForce openSessionPanel;
    "Ctrl+Alt+Delete" = lib.mkForce openSessionPanel;
  };
}
