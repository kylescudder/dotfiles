{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vlc
    spotifyd
    spotify
  ];
}
