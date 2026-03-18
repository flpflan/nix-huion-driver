# Huion Linux Driver (Repackaged for NixOS)

## Disclaimer

This repo is not well tested and may be broken. Use it at your own risk.

## Installation

Add this repo to the `inputs` section of your `flake.nix`, then import the provided NixOS module:

```nix
{
  inputs = {
    huion-driver = {
      url = "github:flpflan/nix-huion-driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, huion-driver, ... }:
    {
      nixosConfigurations."«hostname»" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          huion-driver.nixosModules.default
          ./configuration.nix
        ];
      };
    };
}
```

## Configuration

Enable the Huion driver program. This will automatically add the required udev rules to your system:

```nix
{
    programs.huionDriver.enable = true;

    # Alternatively, use the CN version
    programs.huionDriver.package =
      inputs.huion-driver.packages.x86_64-linux.huionDriverCN;
}
```
