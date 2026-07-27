{
  description = "T3 Code development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkDevShell =
        {
          system,
          pkgs ? import nixpkgs { inherit system; },
          nodejsPackage ? pkgs.nodejs_24,
          corepackPackage ? pkgs.corepack_24,
          extraPackages ? [ ],
          extraShellHook ? "",
        }:
        pkgs.mkShell {
          packages = [
            nodejsPackage
            corepackPackage
            pkgs.git
            pkgs.gnumake
            pkgs.pkg-config
            pkgs.python3
            pkgs.stdenv.cc
          ]
          ++ extraPackages;

          shellHook = ''
            project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
            export PATH="$project_root/node_modules/.bin:$PATH"
            export COREPACK_HOME="''${COREPACK_HOME:-''${XDG_CACHE_HOME:-$HOME/.cache}/t3code/corepack}"
            unset project_root
          ''
          + extraShellHook;
        };
    in
    {
      lib = {
        inherit mkDevShell supportedSystems;
      };

      devShells = forAllSystems (system: {
        default = self.lib.mkDevShell { inherit system; };
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
