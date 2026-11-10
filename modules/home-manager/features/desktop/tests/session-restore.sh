#!/usr/bin/env bash
set -euo pipefail

toggle=${1:?Pass the built session-restore-toggle executable}
launcher=${2:?Pass the built nirinit-optional-restore executable}
test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT
export XDG_STATE_HOME="$test_dir/state"
export XDG_DATA_HOME="$test_dir/data"
export RUNTIME_DIRECTORY="$test_dir/runtime"
export NIRI_SOCKET="$test_dir/niri.first.sock"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$test_dir/no-dbus"
mkdir -p "$RUNTIME_DIRECTORY"
marker="$XDG_STATE_HOME/nirinit/restore-next-session"

"$toggle" 2>/dev/null
test -f "$marker"
"$toggle" 2>/dev/null
test ! -e "$marker"

# Exercise the real launcher up to exec without launching any application.
sed 's|^exec .*|printf "%s\\n" "${restore_args[@]}"|' "$launcher" > "$test_dir/launcher"
bash "$test_dir/launcher" | grep -qx -- --no-restore
test -f "$RUNTIME_DIRECTORY/prepared"

"$toggle" 2>/dev/null
bash "$test_dir/launcher" | grep -qx -- --no-restore
test -f "$marker"

export NIRI_SOCKET="$test_dir/niri.second.sock"
test -z "$(bash "$test_dir/launcher")"
test ! -e "$marker"
bash "$test_dir/launcher" | grep -qx -- --no-restore
printf 'Session restore toggle, one-shot consumption and service restart checks passed.\n'
