{
  programs = {
    sway.enable = true;
    bash.loginShellInit = ''
      if [[ "$(tty)" == /dev/tty1 ]]; then
        exec sway &> /dev/null
      fi
    '';
  };
}
