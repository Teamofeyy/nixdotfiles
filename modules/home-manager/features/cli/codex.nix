{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    pkgs.unstablePkgs.codex
    pkgs.nodejs
  ];

  # Глобальные инструкции Ponytail.
  home.file.".codex/AGENTS.md".source =
    "${inputs.ponytail}/AGENTS.md";
}
