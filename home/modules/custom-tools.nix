{ pkgs, inputs, ... }:
let
  herdr = pkgs.callPackage ../../packages/herdr.nix { };
in
{
  home.packages = with pkgs; [
    cura-appimage
    herdr
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
