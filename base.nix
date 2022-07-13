{ config, pkgs, lib, ... }:
{
  # Remove ZFS
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "ext4" "vfat" ];

  # RISC-V Quirks and patches, should be upstreamed
  nixpkgs.overlays = [
    (final: prev: {
      gusb = prev.gusb.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ prev.gobject-introspection ];
      });
      colord = prev.colord.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ prev.gobject-introspection ];
      });
      cage = prev.cage.overrideAttrs (old: {
        depsBuildBuild = [ prev.pkg-config ];
      });
#      ebook_tools = prev.ebook_tools.overrideAttrs (_old: {
#        preConfigure = ''
#          NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $($PKG_CONFIG --cflags libzip)"
#        '';
#      });
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
    })
  ];

  users = {
    users.default = {
      password = "visionfive-nix";
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
    };
  };
}
