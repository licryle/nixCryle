{ self, inputs, ... }: {
  perSystem = { pkgs, inputs', ... }: {
    packages.noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;

      package = inputs'.noctalia.packages.default; 

      settings =
        (builtins.fromJSON
          (builtins.readFile ./noctalia.json));
    };
  };
}