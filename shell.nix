{pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.05.tar.gz") {}}:
pkgs.mkShell {
  buildInputs = [
    pkgs.alejandra
    pkgs.rnix-lsp
    pkgs.gitlint
    pkgs.codespell
    pkgs.nodePackages.cspell
    pkgs.gh
  ];

  shellHook = ''
  '';

  DIAGNOSTICS = "gitlint:cspell:codespell";
  FORMATTING = "alejandra";
}
