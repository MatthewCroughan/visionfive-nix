{ config, pkgs, lib, ... }:
{
  # Remove ZFS
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "ext4" "vfat" ];

  # Awaiting upstream linux-firmware patch
  # https://lore.kernel.org/all/CADWks+YJm8bi+KPXYTvQ3JrriDW2dcdxfSZ2O5J0vfhfC654Tw@mail.gmail.com/
  # https://github.com/NixOS/nixpkgs/pull/168826#issuecomment-1152990386
  nixpkgs.overlays = [
    (final: prev: {
      linux-firmware = prev.linux-firmware.overrideAttrs (old: {
        postInstall = ''
          cp $out/lib/firmware/brcm/brcmfmac43430-sdio.AP6212.txt \
            $out/lib/firmware/brcm/brcmfmac43430-sdio.starfive,visionfive-v1.txt
        '';
        outputHash = null;
      });
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
      extraGroups = [
        "wheel"
      ];
    };
  };
}
