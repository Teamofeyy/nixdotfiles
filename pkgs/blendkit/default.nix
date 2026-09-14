{
  fetchzip,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "blendkit";
  version = "3.21.0.260628";

  src = fetchzip {
    url = "https://github.com/BlenderKit/Blendkit/releases/download/v${finalAttrs.version}/blenderkit-v${finalAttrs.version}.zip";
    hash = "sha256-kE37l3TMKExPNuQIJsDQWFRJHB3gvn8hDRY7+IWT3K8=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/blender/scripts/addons/blenderkit
    cp -r blenderkit/. $out/share/blender/scripts/addons/blenderkit

    runHook postInstall
  '';

  meta = {
    description = "Online asset library add-on for Blender";
    homepage = "https://www.blendkit.com/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
  };
})
