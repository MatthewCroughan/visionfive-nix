{
  inputs = {
    nixpkgs.url = "github:matthewcroughan/nixpkgs/mc/visionfive-nix";
    jh7100_ddrinit = {
      url = "https://github.com/starfive-tech/JH7100_ddrinit/releases/download/ddrinit-2133-211102/ddrinit-2133-211102.bin.out";
      flake = false;
    };
    jh7100_secondBoot = {
      url = "https://github.com/starfive-tech/JH7100_secondBoot/releases/download/bootloader-211102_VisionFive_JH7100/bootloader-JH7100-211102.bin.out";
      flake = false;
    };
    jh7100_recovery_binary = {
      url = "https://github.com/starfive-tech/bootloader_recovery/releases/download/JH7100_recovery_binary/jh7100_recovery_boot.bin";
      flake = false;
    };
    jh71xx-tools = {
      url = "github:xypron/jh71xx-tools";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, jh71xx-tools, jh7100_recovery_binary, jh7100_secondBoot, jh7100_ddrinit }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-riscv64-visionfive-installer.nix"
        ./base.nix
        ./configuration.nix
      ];
    in
    {
      apps.x86_64-linux = {
        flashBootloader =
          let
            expectScript = pkgs.writeScript "expect-visionfive.sh" ''
              #!${pkgs.expect}/bin/expect -f
              set timeout -1
              spawn ${pkgs.picocom}/bin/picocom [lindex $argv 0] -b 115200 -s "${pkgs.lrzsz}/bin/sz -X"
              expect "bootloader"
              expect "DDR"
              send "\r"
              expect "0:update uboot"
              expect "select the function:"
              send "0\r"
              expect "send file by xmodem"
              expect "CC"
              send "\x01\x13"
              expect "*** file:"
              send "${pkgs.pkgsCross.riscv64.firmware-visionfive}/opensbi_u-boot_visionfive.bin"
              send "\r"
              expect "Transfer complete"
            '';
            program = pkgs.writeShellScript "flash-visionfive.sh" ''
              if $(groups | grep --quiet --word-regexp "dialout"); then
                echo "User is in dialout group, flashing to board without sudo"
                ${expectScript} $1
              else
                echo "User is not in dialout group, flashing to board with sudo"
                sudo ${expectScript} $1
              fi
            '';
          in
          {
            type = "app";
            program = "${program}";
          };
        flashOriginal =
          let
            program = pkgs.writeShellScript "flash-visionfive.sh" ''
              flash() {
                (
                  set -x
                  ${pkgs.lib.getExe self.packages.x86_64-linux.jh7100-recover} \
                    -D $1 \
                    -r ${jh7100_recovery_binary} \
                    -b ${jh7100_secondBoot} \
                    -d ${jh7100_ddrinit}
                )
              }
              if $(groups | grep --quiet --word-regexp "dialout"); then
                echo "User is in dialout group, flashing to board without sudo"
                flash
              else
                echo "User is not in dialout group, flashing to board with sudo"
                sudo flash
              fi
            '';
          in
          {
            type = "app";
            program = "${program}";
          };
        };
      packages.x86_64-linux = {
        jh7100-recover = pkgs.writeCBin "jh7100-recover" (builtins.readFile "${jh71xx-tools}/jh7100-recover.c");
      };
      images = {
        visionfive-cross-x86 = self.nixosConfigurations.visionfive-cross-x86.config.system.build.sdImage;
        visionfive-native = self.nixosConfigurations.visionfive-cross-x86.config.system.build.sdImage;
      };
      nixosConfigurations = {
        visionfive-cross-x86 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = modules ++ [
            {
              nixpkgs.crossSystem = {
                system = "riscv64-linux";
              };
            }
          ];
        };
        visionfive-native = nixpkgs.lib.nixosSystem {
          system = "riscv64-linux";
          modules = modules;
        };
      };
    };
}
