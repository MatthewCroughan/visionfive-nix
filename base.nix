{ config, pkgs, lib, ... }:
{
  # Remove ZFS
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "ext4" "vfat" ];

  # Awaiting upstream linux-firmware patch
  # https://lore.kernel.org/all/CADWks+YJm8bi+KPXYTvQ3JrriDW2dcdxfSZ2O5J0vfhfC654Tw@mail.gmail.com/
  # https://github.com/NixOS/nixpkgs/pull/168826#issuecomment-1152990386
  nixpkgs.overlays = [
    (final: prev: {
#      llvmPackages_14 = let
#        llvmPatch = ''
#          rm test/ExecutionEngine/frem.ll
#          rm test/ExecutionEngine/mov64zext32.ll
#          rm test/ExecutionEngine/test-interp-vec-arithm_float.ll
#          rm test/ExecutionEngine/test-interp-vec-arithm_int.ll
#          rm test/ExecutionEngine/test-interp-vec-logical.ll
#          rm test/ExecutionEngine/test-interp-vec-setcond-fp.ll
#          rm test/ExecutionEngine/test-interp-vec-setcond-int.ll
#          substituteInPlace unittests/Support/CMakeLists.txt \
#            --replace "CrashRecoveryTest.cpp" ""
#          rm unittests/Support/CrashRecoveryTest.cpp
#          substituteInPlace unittests/ExecutionEngine/Orc/CMakeLists.txt \
#            --replace "OrcCAPITest.cpp" ""
#          rm unittests/ExecutionEngine/Orc/OrcCAPITest.cpp
#        '';
#        in prev.llvmPackages_14 // {
#          # FIXME: not sure why I have to override both llvm and libllvm?
#          llvm = prev.llvmPackages_14.llvm.overrideAttrs (old: {
#            postPatch = old.postPatch + llvmPatch;
#          });
#          libllvm = prev.llvmPackages_14.libllvm.overrideAttrs (old: {
#            postPatch = old.postPatch + llvmPatch;
#          });
#        };
      accountsservice = prev.accountsservice.overrideAttrs (_old: { doCheck =
        false;
      });
      gusb = prev.gusb.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ prev.gobject-introspection ];
      });
      colord = prev.colord.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ prev.gobject-introspection ];
      });
      cage = prev.cage.overrideAttrs (old: {
        depsBuildBuild = [ prev.pkg-config ];
#        preConfigure = "PKG_CONFIG_PATH=${pkgs.buildPackages.pkg-config}";
#        nativeBuildInputs = lib.remove pkgs.pkg-config old.nativeBuildInputs;
#        configureFlags = [
#          "--cpu=${pkgs.stdenv.hostPlatform.uname.processor}"
#          "--cross-prefix=${pkgs.stdenv.cc.targetPrefix}"
#        ];
      });
#      gobject-introspection = prev.gobject-introspection.overrideAttrs (old: {
#        strictDeps = true;
#      });
#      libblockdev = prev.libblockdev.overrideAttrs (old: {
#        strictDeps = true;
#      });
#      udisks = prev.udisks.overrideAttrs (old: {
#        strictDeps = true;
#      });
      ebook_tools = prev.ebook_tools.overrideAttrs (_old: {
        preConfigure = ''
          NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $($PKG_CONFIG --cflags libzip)"
        '';
      });
      discount = prev.discount.overrideAttrs (_old: {
        configurePlatforms = [];
      });
      sane-backends = prev.sane-backends.overrideAttrs (_old: {
        CFLAGS = "-DHAVE_MMAP=0";
      });
      curl = prev.curl.overrideAttrs (_old: {
        CFLAGS = "-w";
        LDFLAGS = "-latomic";
      });
      x265 = prev.x265.override { multibitdepthSupport = false; };
#      linux-firmware = prev.linux-firmware.overrideAttrs (old: {
#        postInstall = ''
#          cp $out/lib/firmware/brcm/brcmfmac43430-sdio.AP6212.txt \
#            $out/lib/firmware/brcm/brcmfmac43430-sdio.starfive,visionfive-v1.txt
#        '';
#        outputHash = null;
#      });
    })
  ];

  # Enable ssh on boot
  services = {
    openssh.enable = true;
  };

  users = {
    users.default = {
      password = "visionfive-nix";
      isNormalUser = true;
    };
  };
}
