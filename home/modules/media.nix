{ config, inputs, lib, pkgs, ... }:
let
  spotifydConfig = "${config.xdg.configHome}/spotifyd/spotifyd.conf";
in
{
  imports = [ inputs.spotify-tui.homeManagerModules.default ];

  programs.spotify-tui.enable = true;

  # Use the same daemon as the TUI's packaged runtime.
  services.spotifyd.package =
    inputs.spotify-tui.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.spotifyd;

  # Keep the live config, song-change hook and authentication settings in use.
  # The upstream module otherwise starts spotifyd with a generated store config.
  systemd.user.services.spotifyd.Service.ExecStart = lib.mkForce
    "${config.services.spotifyd.package}/bin/spotifyd --no-daemon --config-path ${spotifydConfig}";
  home.sessionVariables.SPOTIFY_TUI_SPOTIFYD_CONFIG = spotifydConfig;

  home.packages = with pkgs; [
    ffmpeg
    vlc
    spotify
  ];
}
