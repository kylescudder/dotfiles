{ pkgs, ... }:

{
  home.packages = with pkgs; [
    font-awesome
    nerd-fonts.meslo-lg
  ];
}
