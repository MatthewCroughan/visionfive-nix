{ inputs, ... }:
{ lib, pkgs, ... }:
{
  disabledModules = [
    "profiles/all-hardware.nix" # references virtio_pci kernel module, which we don't have
  ];

  config = {
    boot = {
      kernelPackages = pkgs.linuxPackagesFor (import ./package/default.nix { inherit pkgs inputs; });

      kernelParams = [
        "console=tty0"
        "console=ttyS0,115200n8"
        "earlycon=sbi"
      ];

      blacklistedKernelModules = [
        # Last thing to log before crash...
        "axp15060-regulator"
        # Also sus
        "at24"
        # Also also sus
        "jh7110-vin"
        # Maybe??
        "starfive-jh7110-regulator"

        # This one stopped the crashing
        "starfivecamss"
      ];
    };

    # Example: hardware.deviceTree.name = "starfive/jh7110-visionfive-v2-A11.dtb";
    hardware.deviceTree.name = lib.mkDefault "starfive/jh7110-visionfive-v2.dtb";

  };
}
