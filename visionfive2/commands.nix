{ inputs, pkgs }:
let
  wrapSudo = command:
    pkgs.writeShellScript "wrapped.sh" ''
      if $(groups | grep --quiet --word-regexp "dialout"); then
        echo "User is in dialout group, avoiding sudo"
        ${command} "$@"
      else
        echo "User is not in dialout group, using sudo"
        sudo ${command} "$@"
      fi
    '';

  visionFive2_recovery_start =
    let
      expectScript = pkgs.writeScript "expect-visionfive-recoverBootLoader" ''
        #!${pkgs.expect}/bin/expect -f
        set timeout -1
        spawn ${pkgs.picocom}/bin/picocom [lindex $argv 0] -b 115200 -s "${pkgs.lrzsz}/bin/sz -X"
        expect "CC"
        send "\x01\x13"
        expect "*** file:"
        send "${inputs.jh7110_recovery_binary}"
        send "\r"
        expect "Transfer complete"
      '';
      program = pkgs.writeShellScript "flash-visionfive.sh" ''
        echo >&2 NOTE: If your board appears to hang, RX/TX may be flipped,
        echo >&2       _depending on boot setting_!!!
        echo "$0"
        ${expectScript} "$@"
        echo >&2 "Launching new session. Hint enter to display help."
        ${visionFive2_recovery_resume.program} "$@"
      '';
    in { type = "app"; program = "${wrapSudo program}"; };

  visionFive2_recovery_resume =
    let
      program = pkgs.writeScript "recoverBootloader_resume" ''
        #!${pkgs.runtimeShell}
        set -eu
        ${pkgs.picocom}/bin/picocom $1 -b 115200 -s "${pkgs.lrzsz}/bin/sz -X"
      '';
    in { type = "app"; program = "${wrapSudo program}"; };

  visionFive2_bootloader_recover =
    let
      expectScript = pkgs.writeScript "expect-visionfive-recover-bootLoader" ''
        #!${pkgs.expect}/bin/expect -f
        set timeout -1
        spawn ${pkgs.picocom}/bin/picocom [lindex $argv 0] -b 115200 -s "${pkgs.lrzsz}/bin/sz -X"
        expect "CC"
        send "\x01\x13"
        expect "*** file:"
        send "${inputs.jh7110_recovery_binary}"
        send "\r"
        expect "Transfer complete"

        # Wait for menu and install SPL
        expect "0: update 2ndboot/SPL in flash"
        send "0\r"

        expect "CC"
        send "\x01\x13"
        expect "*** file:"
        send "${inputs.jh7110_u-boot-spl-bin}"
        send "\r"
        expect "Transfer complete"

        # Wait for menu and install u-boot
        expect "2: update fw_verif/uboot in flash"
        send "2\r"
        expect "CC"
        send "\x01\x13"
        expect "*** file:"
        send "${inputs.jh7110_u-boot-bin}"
        send "\r"
        expect "Transfer complete"
      '';
      program = pkgs.writeShellScript "flash-visionfive.sh" ''
        cat >&2 <<EOF
        NOTE: If you haven't already switched the boot mode
                  - power off
                  - flip the tiny switches towards the H (as opposed to L)
                    marking on the PCB (towards edge of the board)
        EOF

        ${expectScript} "$@"

        cat >&2 <<EOF
        NOTE: If all went well, flip the switches back to the L (as opposed
              to H) marking on the PCB (away from edge of board).
      '';
    in
    {
      type = "app";
      program = "${wrapSudo program}";
    };

in
{
  inherit
    visionFive2_recovery_start
    visionFive2_recovery_resume
    visionFive2_bootloader_recover
    ;
}