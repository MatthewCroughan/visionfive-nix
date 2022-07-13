{ config, lib, pkgs, ... }:
let
  welcomeMessage = "visionfive-nix";
  xtermWelcomeScript = pkgs.writeScript "xterm-visionfive-welcome.sh" ''
    ${pkgs.figlet}/bin/figlet -c ${welcomeMessage}
    ${pkgs.neofetch}/bin/neofetch
    sh
  '';
in
{
  hardware.opengl.enable = true;
  services.cage = {
    enable = true;
    user = "default";
    program = "${pkgs.xterm}/bin/xterm -fa 'Monospace' -fs 14 -bg black -fg white -e sh -c '${xtermWelcomeScript}'";
  };
}
