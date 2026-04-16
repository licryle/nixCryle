## TODO
## Fix auto update
## Login screen stylings
## Stylix?
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    import-tree = {
      url = "github:vic/import-tree";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      let
        user = "licryle";
        keyboardLayout = "es";
        nixOsVersion = "26.05";
        linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
        darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
        allSystems = linuxSystems ++ darwinSystems;
      in
      {
        systems = allSystems;

        _module.args = { inherit user nixOsVersion keyboardLayout; };

        imports = [
          (inputs.import-tree ./modules)
        ];
      }
    );
}