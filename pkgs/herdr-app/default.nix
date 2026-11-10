{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  fontconfig,
  freetype,
  libxcb,
  libxkbcommon,
  vulkan-loader,
  wayland,
}: let
  appVersion = "0.1.13";
  coreVersion = "0.1.18";

  app = fetchurl {
    url = "https://releases.herdr.dev/app/${appVersion}/herdr-app-linux-x86_64.tar.gz";
    hash = "sha256-d7C+cqRsoUuzZzZaBBZGQfkUs6aXErrDkdOcVqlZvvQ=";
  };

  core = fetchurl {
    url = "https://releases.herdr.dev/core/${coreVersion}/herdr-core-linux-x86_64.tar.gz";
    hash = "sha256-Wy+Xy0sqnXprLMWUJiggPtn7t8wMK0sJrYpvVkjiRrc=";
  };

  runtimeLibraries = [
    fontconfig
    freetype
    libxcb
    libxkbcommon
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
  ];
in
  stdenv.mkDerivation {
    pname = "herdr-app";
    version = appVersion;

    dontUnpack = true;

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
    ];

    buildInputs = runtimeLibraries;
    runtimeDependencies = runtimeLibraries;

    desktopItems = [
      (makeDesktopItem {
        name = "herdr-app";
        desktopName = "Herdr";
        comment = "Terminals and coding agents that keep running";
        exec = "herdr-app";
        icon = "herdr-app";
        categories = ["Development"];
        startupWMClass = "herdr-app";
      })
    ];

    installPhase = ''
      runHook preInstall

      app_source="$TMPDIR/herdr-app-source"
      core_source="$TMPDIR/herdr-core-source"
      mkdir -p "$app_source" "$core_source"
      tar -xzf ${app} -C "$app_source"
      tar -xzf ${core} -C "$core_source"

      mkdir -p "$out/bin" "$out/libexec/herdr-app"
      install -Dm755 "$app_source/herdr-app/herdr-app" "$out/libexec/herdr-app/herdr-app"
      install -Dm755 "$core_source/herdr-core" "$out/bin/herdr-core"
      ln -s herdr-core "$out/bin/hc"

      # Keep the icon outside the executable directory. The upstream release
      # uses an adjacent icon to detect mutable installs and self-update them;
      # Nix packages are updated through the flake instead.
      install -Dm644 "$app_source/herdr-app/herdr-app.svg" \
        "$out/share/icons/hicolor/scalable/apps/herdr-app.svg"

      install -Dm644 "$app_source/herdr-app/LICENSE" "$out/share/licenses/herdr-app/LICENSE"
      install -Dm644 "$app_source/herdr-app/THIRD-PARTY-NOTICES" \
        "$out/share/licenses/herdr-app/THIRD-PARTY-NOTICES"
      install -Dm644 "$core_source/LICENSE" "$out/share/licenses/herdr-core/LICENSE"
      install -Dm644 "$core_source/THIRD-PARTY-NOTICES" \
        "$out/share/licenses/herdr-core/THIRD-PARTY-NOTICES"

      makeWrapper "$out/libexec/herdr-app/herdr-app" "$out/bin/herdr-app" \
        --prefix PATH : "$out/bin" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}"

      runHook postInstall
    '';

    meta = {
      description = "Desktop workspace for terminals and coding agents";
      homepage = "https://herdr.dev";
      license = lib.licenses.asl20;
      mainProgram = "herdr-app";
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
