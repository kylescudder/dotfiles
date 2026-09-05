{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg
    vlc
    spotify-player
    spotifyd
    spotify
  ];
}
