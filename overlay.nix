final: prev: {
  huionDriver = prev.callPackage ./package.nix { };
  huionDriverDN = prev.callPackage ./package.nix { cnVersion = true; };
}
