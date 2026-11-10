{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    pkgs.codex
    pkgs.nodejs
  ];

  # Глобальные инструкции Ponytail.
  home.file.".codex/AGENTS.md".source =
    "${inputs.ponytail}/AGENTS.md";
}
