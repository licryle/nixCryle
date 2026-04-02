{ self, inputs, ... }: {
  perSystem = { pkgs, inputs', ... }: {
    packages.featureNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;

      package = inputs'.noctalia.packages.default; 

      settings = {};
    };
  };
}