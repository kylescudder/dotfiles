{ config, lib, pkgs, inputs, username, ... }:
let
  dotfilesRoot = inputs.self;
  # Reproduce GNU Stow's useful behaviour without keeping Stow itself.
  # Each package is treated as a tree relative to $HOME. Home Manager creates
  # managed links for every file while retaining the existing repo layout.
  stowPackages = [
    "hyprland"
    "waybar"
    "nvim"
    "spotifyd"
    "starship"
    "bashrc"
    "zsh"
    "fastfetch"
    "rofi"
    "yazi"
    "ghostty"
    "btop"
    "wlogout"
    "scripts"
  ];

  filesForPackage = packageName:
    let
      root = dotfilesRoot + "/${packageName}";
      files = lib.filesystem.listFilesRecursive root;
      rootString = toString root + "/";
    in
      builtins.listToAttrs (map (path: {
      name = builtins.unsafeDiscardStringContext (
        lib.removePrefix rootString (toString path)
      );
        value.source = path;
      }) files);

  stowedFiles = lib.foldl' lib.recursiveUpdate { }
    (map filesForPackage stowPackages);

  herdr = pkgs.callPackage ../packages/herdr.nix { };
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keep existing dotfiles as source-of-truth initially. This is deliberately
  # a migration layer: individual configs can later be converted to native
  # Home Manager modules without changing everything at once.
  home.file = stowedFiles // {
    # The old bootstrap Stowed these packages both into $HOME and into
    # ~/.local/share. Only the XDG destinations are intentional.
    ".local/share/applications" = {
      source = dotfilesRoot + "/applications/applications";
      recursive = true;
    };
    ".local/share/icons" = {
      source = dotfilesRoot + "/icons/icons";
      recursive = true;
    };
    ".local/share/wallpapers" = {
      source = dotfilesRoot + "/wallpapers/wallpapers";
      recursive = true;
    };

    # 1Password SSH agent selection. This file contains configuration, not a
    # secret. Private keys remain in 1Password and never enter the Nix store.
    ".config/1Password/ssh/agent.toml".text = ''
      [[ssh-keys]]
      vault = "Private"
    '';
  };

  # Use the 1Password agent consistently for ssh, git and terminal sessions.
  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      identityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Kyle Scudder";
      email = "kyle@kylescudder.co.uk";
    };
  };

  # Keep the existing .zshrc and Starship config rather than generating them.
  # Nix provides the binaries; the repo still owns their current config files.
  programs.zsh.enable = false;
  programs.starship.enable = false;

  programs.vesktop.enable = true;

  # Replaces the curl-to-~/.config/swaync Catppuccin installation.
  catppuccin.swaync = {
    enable = true;
    flavor = "mocha";
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

    # Terminal / CLI
    ghostty
    starship
    fastfetch
    yazi
    btop
    feh
    picom

    # Hyprland desktop utilities
    inputs.hyprland-guiutils.packages.${pkgs.system}.default
    hyprshot
    rofi 
    waybar
    swaynotificationcenter
    hyprlock
    hypridle
    hyprpaper
    wlogout
    pavucontrol

    # Desktop applications
    vlc
    obsidian
    thunderbird
    prismlauncher
    spotifyd
    spotify
    spicetify-cli
    cura-appimage

    # Fonts
    font-awesome
    nerd-fonts.meslo-lg

    # Existing custom tool, now built reproducibly from its Cargo.lock.
    herdr

    # Helium is not in the stable nixpkgs set used here, so consume its flake.
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # `bide` from the Arch bootstrap is intentionally not silently replaced:
  # the AUR package is an old Java-8-specific BIDE package and there is no
  # equivalent package in current nixpkgs. See README-NIXOS.md.

  home.stateVersion = "26.05";
}
