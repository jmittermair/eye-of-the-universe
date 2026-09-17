{
  description = "Dendritic NixOS configurations for the Outer Wilds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    stylix = {
      url = "github:nix-community/stylix/pull/2337/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango.url = "github:mangowm/mango";
    noctalia.url = "github:noctalia-dev/noctalia";
    walker.url = "github:abenz1267/walker";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules/features)
        ./modules/hosts/thestranger
      ];
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem = { pkgs, ... }: {
        formatter = pkgs.writeShellApplication {
          name = "format-config";
          runtimeInputs = [ pkgs.nixfmt ];
          text = ''
            nixfmt "$@" flake.nix modules/features/*.nix \
              modules/hosts/thestranger/default.nix tests/*.nix
          '';
        };
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
            statix
            deadnix
          ];
        };
      };
    };
}
