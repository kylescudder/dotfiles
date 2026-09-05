{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg
    vlc
    spotifyd
    spotify
  ];
}
