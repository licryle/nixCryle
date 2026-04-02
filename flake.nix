{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
  {
    imports = []
    systems = [ "x86_64-linux" "x86_64-darwin" ];
    perSystem = { pkgs, ... }: {
      packages.mypackage = pkgs.ls;
      devShell.defaults = pkgs.mkSHell {
        packages = [ self'.packages.mypackage ];
      };
    };
  };
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    nixosConfigurations.nixCryle = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs };
      modules = [ ./configuration.nix ];
    };
  };
}

