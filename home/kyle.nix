{ pkgs, inputs, username, ... }:
let
  herdr = pkgs.callPackage ../packages/herdr.nix { };
  bedrockOnLinux = pkgs.callPackage ../packages/bedrock-on-linux.nix { };
in
{
  imports = [
    ./modules/dotfiles.nix
    ./modules/ssh.nix
    ./modules/git.nix
    ./modules/audio.nix
    ./modules/t3code.nix
    ./modules/shell.nix
    ./modules/development.nix
    ./modules/terminal.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.vesktop.enable = true;

  # Replaces the curl-to-~/.config/swaync Catppuccin installation.
  catppuccin = {
    enable = true;
    autoEnable = false;

    swaync = {
      enable = true;
      flavor = "mocha";
    };
  };

  # The previous gsettings calls become deterministic user dconf values.
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
  };

  home.packages = with pkgs; [
    # Audio utilities used by the workstation audio setup and switch scripts.
    pulseaudio
    alsa-utils

    # Desktop / compositor utilities
    feh
    picom
    inputs.hyprland-guiutils.packages.${pkgs.stdenv.hostPlatform.system}.default
    hyprshot
    rofi
    waybar
    swaynotificationcenter
    hyprlock
    hypridle
    hyprpaper
    wlogout
    pavucontrol
    playerctl
    brightnessctl
    libnotify
    file
    lua

    # Desktop applications
    vlc
    obsidian
    thunderbird
    prismlauncher
    spotifyd
    spotify
    cura-appimage

    # Games
    bedrockOnLinux

    # Fonts
    font-awesome
    nerd-fonts.meslo-lg

    # Existing custom tool, packaged from the published release binary.
    herdr

    # Helium is not in the stable nixpkgs set used here, so consume its flake.
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Bide is intentionally not packaged yet.

  home.stateVersion = "26.05";
}
