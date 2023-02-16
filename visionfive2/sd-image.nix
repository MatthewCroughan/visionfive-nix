{ inputs, importApply, ... }:
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/installer/sd-card/sd-image.nix")
    (importApply ./kernel/nixos-module.nix { inherit inputs; })
  ];

  environment.systemPackages = with pkgs; [ mtdutils ];

  boot = {
    consoleLogLevel = lib.mkDefault 7;

    initrd.kernelModules = [
      # "dw-axi-dmac-platform"
    ];
    initrd.includeDefaultModules = false;
    initrd.availableKernelModules = [
      "dw_mmc-pltfm"
      "dw_mmc-starfive"
      "spi-dw-mmio"
      "mmc_block"
      "nvme"
      "sdhci" #?
      "sdhci-pci" #?
      "sdhci-of-dwcmshc"
    ];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

  };

  sdImage = {
    imageName = "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}-visionfive-2.img";

    populateFirmwareCommands = ''
    '';

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}