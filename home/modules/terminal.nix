{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghostty
    kitty
    starship
    fastfetch
    yazi
    btop
  ];
}
