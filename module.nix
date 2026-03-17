self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  driver-default = self.packages.${system}.default;
  cfg = config.huionDriver;
in
{
  options.huionDriver = with lib; {
    enable = mkEnableOption "Enable Huion tablet driver and udev rules";
    package = mkOption {
      type = types.package;
      default = driver-default;
      description = "The package of Huion tablet driver";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.udev.packages = [ cfg.package ];

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0666"
    '';
  };
}
