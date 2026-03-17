{
  description = "Huion tablet linux driver and udev rules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      pkgsFor = nixpkgs.legacyPackages;
    in
    {
      nixosModules = {
        huionDriver = nixpkgs.lib.importApply ./module.nix self;
        default = self.nixosModules.huionDriver;
      };

      # overlays.default = import ./overlay.nix;

      packages = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
        in
        {
          huionDriver = pkgs.callPackage ./package.nix { };
          huionDriverCN = pkgs.callPackage ./package.nix { cnVersion = true; };
          default = self.packages.${system}.huionDriver;
        }
      );
    };
}
