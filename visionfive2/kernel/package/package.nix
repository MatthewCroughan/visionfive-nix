{ lib
, fetchFromGitHub
, fetchpatch
, buildLinux
, src
, ... } @ args:

let
  kernelVersion = rec {
    # Fully constructed string, example: "5.10.0-rc5".
    string = "${version + "." + patchlevel + "." + sublevel + (lib.optionalString (extraversion != "") extraversion)}";
    file = "${src}/Makefile";
    version = toString (builtins.match ".+VERSION = ([0-9]+).+" (builtins.readFile file));
    patchlevel = toString (builtins.match ".+PATCHLEVEL = ([0-9]+).+" (builtins.readFile file));
    sublevel = toString (builtins.match ".+SUBLEVEL = ([0-9]+).+" (builtins.readFile file));
    # rc, next, etc.
    extraversion = toString (builtins.match ".+EXTRAVERSION = ([a-z0-9-]+).+" (builtins.readFile file));
  };
  modDirVersion = "${kernelVersion.string}";
in buildLinux (args // {
  inherit modDirVersion;
  version = "${modDirVersion}-visionfive2";

  inherit src;

  kernelPatches = [
    { patch = fetchpatch {
        url = "https://github.com/torvalds/linux/commit/215bebc8c6ac438c382a6a56bd2764a2d4e1da72.diff";
        hash = "sha256-1ZqmVOkgcDBRkHvVRPH8I5G1STIS1R/l/63PzQQ0z0I=";
        includes = ["security/keys/dh.c"];
      };
    }
    { patch = ./visionfive-2-duplicate-init-module.patch; }
    { patch = ./visionfive-2-pl330-name-collision.patch; }
    { patch = ./visionfive-2-gpu.patch; }
  ];

  defconfig = "starfive_visionfive2_defconfig";

  structuredExtraConfig = with lib.kernel; {

    # USB Wifi
    RT2800USB_RT53XX = yes;
    RT2800USB = module;
    RT2800USB_RT3573 = yes;

    KEXEC = yes;
    SERIAL_8250_DW = yes;

    SOC_STARFIVE = yes;

    # CLK_STARFIVE_JH7110_SYS = yes;
    RESET_STARFIVE_JH7110 = yes;
    PINCTRL_STARFIVE_JH7110 = yes;

    # MMC_DW_STARFIVE = yes;

    # # Doesn't build as a module
    # DW_AXI_DMAC_STARFIVE = yes;

    # # stmmac hangs when built as a module (at least on VisionFive v1, apparently)
    PTP_1588_CLOCK = yes;
    STMMAC_ETH = yes;
    STMMAC_PCI = yes;

    # Fix build error
    # RIPE-MD and other algos appears to have been removed, correlating with https://github.com/starfive-tech/linux/commit/d210ee3fdfe8584f84f8fdd0ac4a9895d023325b
    # defconfig out of date?
    CRYPTO_RMD128 = no;
    CRYPTO_RMD160 = yes;
    CRYPTO_RMD256 = no;
    CRYPTO_RMD320 = no;
    CRYPTO_TGR192 = no;
    CRYPTO_SALSA20 = no;

    # sm4 lacks a symbol
    CRYPTO_DEV_CCREE = no;
    CRYPTO_SM4 = no;

    # Can't be built as modules
    SPI_PL022 = yes;
    SPI_PL022_STARFIVE = yes;
    RTC_DRV_STARFIVE = yes;

    # Compile errors
    STARFIVE_DSI = no;
    VIDEO_HDPVR = no;
    VIDEO_PVRUSB2_DVB = no;
    DRM_IMG = no;           # gpu module doesn't compile at this time
    DRM_IMG_ROGUE = no;
    DRM_VERISILICON = no;
    # DRM_LEGACY = no;
    DRM_PANEL_JADARD_JD9365DA_H3 = no;
    VERISILICON_DW_MIPI_DSI = no;
    VGA_ARB = no;

    # brute force disable drm
    CEC_CORE = no;
    CEC_NOTIFIER = no;
    DRM = no;
    DRM_MIPI_DBI = no;
    DRM_MIPI_DSI = no;
    DRM_DP_AUX_BUS = no;
    DRM_DP_AUX_CHARDEV = lib.mkForce no;
    DRM_KMS_HELPER = no;
    DRM_FBDEV_EMULATION = no;
    DRM_LOAD_EDID_FIRMWARE = lib.mkForce no;
    DRM_TTM = no;
    DRM_VRAM_HELPER = no;
    DRM_TTM_HELPER = no;
    DRM_GEM_CMA_HELPER = no;
    DRM_KMS_CMA_HELPER = no;
    DRM_GEM_SHMEM_HELPER = no;
    DRM_SCHED = no;
    DRM_I2C_CH7006 = no;
    DRM_I2C_SIL164 = no;
    DRM_I2C_NXP_TDA998X = no;
    DRM_I2C_NXP_TDA9950 = no;
    DRM_KOMEDA = no;
    DRM_RADEON = no;
    DRM_AMDGPU = no;
    DRM_AMDGPU_SI = lib.mkForce no;
    DRM_AMDGPU_CIK = lib.mkForce no;
    DRM_AMDGPU_USERPTR = lib.mkForce no;
    DRM_AMD_DC = no;
    DRM_AMD_DC_HDCP = lib.mkForce no;
    DRM_AMD_DC_SI = lib.mkForce no;
    DRM_NOUVEAU = no;
    NOUVEAU_LEGACY_CTX_SUPPORT = no;
    DRM_NOUVEAU_BACKLIGHT = no;
    DRM_VGEM = no;
    DRM_VKMS = no;
    DRM_UDL = no;
    DRM_AST = no;
    DRM_MGAG200 = no;
    DRM_RCAR_DW_HDMI = no;
    DRM_QXL = no;
    DRM_VIRTIO_GPU = no;
    DRM_PANEL = no;
    DRM_PANEL_ABT_Y030XX067A = no;
    DRM_PANEL_ARM_VERSATILE = no;
    DRM_PANEL_ASUS_Z00T_TM5P5_NT35596 = no;
    DRM_PANEL_BOE_HIMAX8279D = no;
    DRM_PANEL_BOE_TV101WUM_NL6 = no;
    DRM_PANEL_DSI_CM = no;
    DRM_PANEL_LVDS = no;
    DRM_PANEL_SIMPLE = no;
    DRM_PANEL_ELIDA_KD35T133 = no;
    DRM_PANEL_FEIXIN_K101_IM2BA02 = no;
    DRM_PANEL_FEIYANG_FY07024DI26A30D = no;
    DRM_PANEL_ILITEK_IL9322 = no;
    DRM_PANEL_ILITEK_ILI9341 = no;
    DRM_PANEL_ILITEK_ILI9881C = no;
    DRM_PANEL_INNOLUX_EJ030NA = no;
    DRM_PANEL_INNOLUX_P079ZCA = no;
    DRM_PANEL_JDI_LT070ME05000 = no;
    DRM_PANEL_KHADAS_TS050 = no;
    DRM_PANEL_KINGDISPLAY_KD097D04 = no;
    DRM_PANEL_LEADTEK_LTK050H3146W = no;
    DRM_PANEL_LEADTEK_LTK500HD1829 = no;
    DRM_PANEL_SAMSUNG_LD9040 = no;
    DRM_PANEL_LG_LB035Q02 = no;
    DRM_PANEL_LG_LG4573 = no;
    DRM_PANEL_NEC_NL8048HL11 = no;
    DRM_PANEL_NOVATEK_NT35510 = no;
    DRM_PANEL_NOVATEK_NT36672A = no;
    DRM_PANEL_NOVATEK_NT39016 = no;
    DRM_PANEL_MANTIX_MLAF057WE51 = no;
    DRM_PANEL_OLIMEX_LCD_OLINUXINO = no;
    DRM_PANEL_ORISETECH_OTM8009A = no;
    DRM_PANEL_OSD_OSD101T2587_53TS = no;
    DRM_PANEL_PANASONIC_VVX10F034N00 = no;
    DRM_PANEL_RASPBERRYPI_TOUCHSCREEN = no;
    DRM_PANEL_RAYDIUM_RM67191 = no;
    DRM_PANEL_RAYDIUM_RM68200 = no;
    DRM_PANEL_RONBO_RB070D30 = no;
    DRM_PANEL_SAMSUNG_ATNA33XC20 = no;
    DRM_PANEL_SAMSUNG_DB7430 = no;
    DRM_PANEL_SAMSUNG_S6D16D0 = no;
    DRM_PANEL_SAMSUNG_S6E3HA2 = no;
    DRM_PANEL_SAMSUNG_S6E63J0X03 = no;
    DRM_PANEL_SAMSUNG_S6E63M0 = no;
    DRM_PANEL_SAMSUNG_S6E63M0_SPI = no;
    DRM_PANEL_SAMSUNG_S6E63M0_DSI = no;
    DRM_PANEL_SAMSUNG_S6E88A0_AMS452EF01 = no;
    DRM_PANEL_SAMSUNG_S6E8AA0 = no;
    DRM_PANEL_SAMSUNG_SOFEF00 = no;
    DRM_PANEL_SEIKO_43WVF1G = no;
    DRM_PANEL_SHARP_LQ101R1SX01 = no;
    DRM_PANEL_SHARP_LS037V7DW01 = no;
    DRM_PANEL_SHARP_LS043T1LE01 = no;
    DRM_PANEL_SITRONIX_ST7701 = no;
    DRM_PANEL_SITRONIX_ST7703 = no;
    DRM_PANEL_SITRONIX_ST7789V = no;
    DRM_PANEL_SONY_ACX565AKM = no;
    DRM_PANEL_TDO_TL070WSH30 = no;
    DRM_PANEL_TPO_TD028TTEC1 = no;
    DRM_PANEL_TPO_TD043MTEA1 = no;
    DRM_PANEL_TPO_TPG110 = no;
    DRM_PANEL_TRULY_NT35597_WQXGA = no;
    DRM_PANEL_VISIONOX_RM69299 = no;
    DRM_PANEL_WIDECHIPS_WS2401 = no;
    DRM_PANEL_XINPENG_XPP055C272 = no;
    DRM_BRIDGE = no;
    DRM_PANEL_BRIDGE = no;
    DRM_CDNS_DSI = no;
    DRM_CHIPONE_ICN6211 = no;
    DRM_CHRONTEL_CH7033 = no;
    DRM_DISPLAY_CONNECTOR = no;
    DRM_LONTIUM_LT8912B = no;
    DRM_LONTIUM_LT9611 = no;
    DRM_LONTIUM_LT9611UXC = no;
    DRM_ITE_IT66121 = no;
    DRM_LVDS_CODEC = no;
    DRM_MEGACHIPS_STDPXXXX_GE_B850V3_FW = no;
    DRM_NWL_MIPI_DSI = no;
    DRM_NXP_PTN3460 = no;
    DRM_PARADE_PS8622 = no;
    DRM_PARADE_PS8640 = no;
    DRM_SIL_SII8620 = no;
    DRM_SII902X = no;
    DRM_SII9234 = no;
    DRM_SIMPLE_BRIDGE = no;
    DRM_THINE_THC63LVD1024 = no;
    DRM_TOSHIBA_TC358762 = no;
    DRM_TOSHIBA_TC358764 = no;
    DRM_TOSHIBA_TC358767 = no;
    DRM_TOSHIBA_TC358768 = no;
    DRM_TOSHIBA_TC358775 = no;
    DRM_TI_TFP410 = no;
    DRM_TI_SN65DSI83 = no;
    DRM_TI_SN65DSI86 = no;
    DRM_TI_TPD12S015 = no;
    DRM_ANALOGIX_ANX6345 = no;
    DRM_ANALOGIX_ANX78XX = no;
    DRM_ANALOGIX_DP = no;
    DRM_ANALOGIX_ANX7625 = no;
    DRM_I2C_ADV7511 = no;
    DRM_I2C_ADV7511_CEC = no;
    DRM_CDNS_MHDP8546 = no;
    DRM_DW_HDMI = no;
    DRM_DW_HDMI_AHB_AUDIO = no;
    DRM_DW_HDMI_I2S_AUDIO = no;
    DRM_DW_HDMI_CEC = no;
    DRM_ETNAVIV = no;
    DRM_ETNAVIV_THERMAL = no;
    DRM_MXS = no;
    DRM_MXSFB = no;
    DRM_ARCPGU = no;
    DRM_BOCHS = no;
    DRM_CIRRUS_QEMU = no;
    DRM_GM12U320 = no;
    TINYDRM_HX8357D = no;
    TINYDRM_ILI9225 = no;
    TINYDRM_ILI9341 = no;
    TINYDRM_ILI9486 = no;
    TINYDRM_MI0283QT = no;
    TINYDRM_REPAPER = no;
    TINYDRM_ST7586 = no;
    TINYDRM_ST7735R = no;
    DRM_GUD = no;
    DRM_LEGACY = no;
    DRM_TDFX = no;
    DRM_R128 = no;
    DRM_MGA = no;
    DRM_VIA = no;
    DRM_SAVAGE = no;
    VIDEOMODE_HELPERS = no;
    SND_PCM_ELD = no;
    SND_PCM_IEC958 = no;
    SND_HDA_COMPONENT = no;
    SND_SOC_HDMI_CODEC = no;
    VIRTIO_DMA_SHARED_BUFFER = no;

    #end

    USB_WIFI_ECR6600U = no;
    VIN_SENSOR_IMX219 = no;
    VIDEO_IMX219 = no;

    VIN_SENSOR_OV5640 = no;
    VIDEO_OV5640 = no;

    # missing MODULE_LICENSE()
    SND_SOC_WM8960 = no;

    # # Wonky config generation? Its dependency and dependent are enabled as module,
    # # but VIRTIO_PCI itself was not listed in the .config
    # # Error was: modprobe: FATAL: Module virtio_pci not found in directory
    # VIRTIO = no;
    # VIRTIO_PCI = module;
    # VIRTIO_PCI_LIB = no;
    # # VIRTIO_VSOCKETS = no;
    # # BT_VIRTIO = no;
    # # NET_9P_VIRTIO = no;
    # # VIRTIO_BLK = no;
    # # SCSI_VIRTIO = no;
    # # VIRTIO_NET = no;
    # # VIRTIO_CONSOLE = no;
    # # HW_RANDOM_VIRTIO = no;
    # # I2C_VIRTIO = no;
    # # GPIO_VIRTIO = no;
    # # SND_VIRTIO = no;
    # # VIRTIO_MENU = no;
    # # RPMSG_VIRTIO = no;
    # # VIRTIO_FS = no;
    # # CRYPTO_DEV_VIRTIO = no;

    # SND_SOC_STARFIVE_PWMDAC = yes;
    # SND_SOC_STARFIVE = yes;
    # SND = no;
  };

  extraMeta = {
    description = "Linux kernel for StarFive's JH7110 RISC-V SoC (VisionFive 2)";
    platforms = [ "riscv64-linux" ];
    hydraPlatforms = [ "riscv64-linux" ];
  };
} // (args.argsOverride or { }))
