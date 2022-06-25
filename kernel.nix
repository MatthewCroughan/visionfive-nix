{ lib
, fetchFromGitHub
, buildLinux
, ... } @ args:

let
  modDirVersion = "5.18.5";
in buildLinux (args // {
  inherit modDirVersion;
  version = "${modDirVersion}-visionfive";

  src = fetchFromGitHub {
    owner = "starfive-tech";
    repo = "linux";
    rev = "8fb50a9b3e5d401d4ec169c858e8b7ba0a542955";
    sha256 = "sha256-kjOoNJhmmQdpmtx0m1ZovH3mj2x4NB6iInEknxZq8Dw=";
  };

  kernelPatches = [];

  defconfig = "starfive_jh7100_fedora_defconfig";

  structuredExtraConfig = with lib.kernel; {
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
    branch = "visionfive-5.18.y";
    description = "Linux kernel for StarFive's JH7100 RISC-V SoC (VisionFive)";
    platforms = [ "riscv64-linux" ];
    hydraPlatforms = [ "riscv64-linux" ];
  };
} // (args.argsOverride or { }))
