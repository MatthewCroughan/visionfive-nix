{ lib
, fetchFromGitHub
, buildLinux
, vendor-kernel
, ... } @ args:

let
  kernelVersion = rec {
    # Fully constructed string, example: "5.10.0-rc5".
    string = "${version + "." + patchlevel + "." + sublevel + (lib.optionalString (extraversion != "") extraversion)}";
    file = "${vendor-kernel}/Makefile";
    version = toString (builtins.match ".+VERSION = ([0-9]+).+" (builtins.readFile file));
    patchlevel = toString (builtins.match ".+PATCHLEVEL = ([0-9]+).+" (builtins.readFile file));
    sublevel = toString (builtins.match ".+SUBLEVEL = ([0-9]+).+" (builtins.readFile file));
    # rc, next, etc.
    extraversion = toString (builtins.match ".+EXTRAVERSION = ([a-z0-9-]+).+" (builtins.readFile file));
  };
  modDirVersion = "${kernelVersion.string}";
in buildLinux (args // {
  inherit modDirVersion;
  version = "${modDirVersion}-visionfive";

  src = vendor-kernel;

  kernelPatches = [];

  defconfig = "starfive_jh7100_fedora_defconfig";

  structuredExtraConfig = with lib.kernel; {
    KEXEC = yes;
    SERIAL_8250_DW = yes;
    PINCTRL_STARFIVE = yes;

    # Doesn't build as a module
    DW_AXI_DMAC_STARFIVE = yes;

    # stmmac hangs when built as a module
    PTP_1588_CLOCK = yes;
    STMMAC_ETH = yes;
    STMMAC_PCI = yes;
  };

  extraMeta = {
    description = "Linux kernel for StarFive's JH7100 RISC-V SoC (VisionFive)";
    platforms = [ "riscv64-linux" ];
    hydraPlatforms = [ "riscv64-linux" ];
  };
} // (args.argsOverride or { }))
