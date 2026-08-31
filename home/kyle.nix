{ config, lib, pkgs, inputs, username, ... }:
let
  # The checked-out repository is the editable source of truth.
  liveDotfilesRoot =
    "${config.home.homeDirectory}/Documents/Repos/dotfiles";

  # We still use the flake/store copy only to discover which files exist.
  # The links themselves point back to the live Git checkout.
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
      storeRoot = inputs.self + "/${packageName}";
      files = lib.filesystem.listFilesRecursive storeRoot;
      storeRootString = toString storeRoot + "/";
    in
    builtins.listToAttrs (
      map
        (path:
          let
            relativePath = builtins.unsafeDiscardStringContext (
              lib.removePrefix storeRootString (toString path)
            );
          in
          {
            name = relativePath;
            value.source =
              config.lib.file.mkOutOfStoreSymlink
                "${liveDotfilesRoot}/${packageName}/${relativePath}";
          })
        files
    );

  filesForSharePackage = packageName: sourceDirectory: destinationDirectory:
    let
      storeRoot = inputs.self + "/${packageName}/${sourceDirectory}";
      files = lib.filesystem.listFilesRecursive storeRoot;
      storeRootString = toString storeRoot + "/";
    in
    builtins.listToAttrs (
      map
        (path:
          let
            relativePath = builtins.unsafeDiscardStringContext (
              lib.removePrefix storeRootString (toString path)
            );
          in
          {
            name = "${destinationDirectory}/${relativePath}";
            value.source =
              config.lib.file.mkOutOfStoreSymlink
                "${liveDotfilesRoot}/${packageName}/${sourceDirectory}/${relativePath}";
          })
        files
    );

  stowedFiles =
    lib.foldl' lib.recursiveUpdate { }
      (map filesForPackage stowPackages);

  shareFiles =
    lib.foldl' lib.recursiveUpdate { } [
      (filesForSharePackage
        "applications"
        "applications"
        ".local/share/applications")

      (filesForSharePackage
        "icons"
        "icons"
        ".local/share/icons")

      (filesForSharePackage
        "wallpapers"
        "wallpapers"
        ".local/share/wallpapers")
    ];

  herdr = pkgs.callPackage ../packages/herdr.nix { };
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keep existing dotfiles as source-of-truth initially. This is deliberately
  # a migration layer: individual configs can later be converted to native
  # Home Manager modules without changing everything at once.
  home.file = stowedFiles // shareFiles // {
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
