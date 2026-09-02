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
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keep the existing .zshrc and Starship config rather than generating them.
  # Nix provides the binaries; the repo still owns their current config files.
  programs.zsh.enable = false;
  programs.starship.enable = false;

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
    # Development
    nodejs
    bun
    dotnet-sdk
    neovim
    lazygit
    python3
    python3Packages.pip
    fzf
    pulseaudio
    alsa-utils

    # Terminal / CLI
    ghostty
    starship
    fastfetch
    yazi
    btop
    feh
    picom

    # Hyprland desktop utilities
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
