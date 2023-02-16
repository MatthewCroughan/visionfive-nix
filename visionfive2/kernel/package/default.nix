{ pkgs, inputs }:

pkgs.callPackage ./package.nix { src = inputs.jh7110-kernel; }