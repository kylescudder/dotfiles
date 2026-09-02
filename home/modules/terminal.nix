{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghostty
    starship
    fastfetch
    yazi
    btop
  ];
}
