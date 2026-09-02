{ config, lib, pkgs, inputs, username, ... }:
let
  liveDotfilesRoot =
    "${config.home.homeDirectory}/Documents/Repos/dotfiles";

  linkPackage = packageName: destinationRoot:
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
            name =
              if destinationRoot == ""
              then relativePath
              else "${destinationRoot}/${relativePath}";

            value.source =
              config.lib.file.mkOutOfStoreSymlink
                "${liveDotfilesRoot}/${packageName}/${relativePath}";
          })
        files
    );

  dotfiles =
    lib.foldl' lib.recursiveUpdate { } [
      (linkPackage "hyprland" ".config/hypr")
      (linkPackage "waybar" ".config/waybar")
      (linkPackage "nvim" ".config/nvim")
      (linkPackage "spotifyd" ".config/spotifyd")
      (linkPackage "fastfetch" ".config/fastfetch")
      (linkPackage "rofi" ".config/rofi")
      (linkPackage "yazi" ".config/yazi")
      (linkPackage "ghostty" ".config/ghostty")
      (linkPackage "btop" ".config/btop")
      (linkPackage "wlogout" ".config/wlogout")

      (linkPackage "starship" ".config")

      (linkPackage "bashrc" "")
      (linkPackage "zsh" "")

      (linkPackage "scripts" ".local/bin")
      (linkPackage "applications" ".local/share/applications")
      (linkPackage "icons" ".local/share/icons")
      (linkPackage "wallpapers" ".local/share/wallpapers")
    ];

  herdr = pkgs.callPackage ../packages/herdr.nix { };
  bedrockOnLinux = pkgs.callPackage ../packages/bedrock-on-linux.nix { };
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keep existing dotfiles as source-of-truth initially. This is deliberately
  # a migration layer: individual configs can later be converted to native
  # Home Manager modules without changing everything at once.
  home.file = dotfiles // {
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

    settings."*" = {
      IdentityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Kyle Scudder";
      email = "kyle@kylescudder.co.uk";
    };
  };

  programs.t3code = {
    enable = true;

    package =
      inputs.nixpkgs-t3.legacyPackages.${pkgs.stdenv.hostPlatform.system}.t3code;
  };

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

  systemd.user.services.audio-setup = {
    Unit = {
      Description = "Configure workstation audio outputs";
      After = [
        "pipewire.service"
        "wireplumber.service"
      ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "audio-setup" ''
        ${pkgs.pulseaudio}/bin/pactl set-card-profile \
          alsa_card.pci-0000_00_1f.3 pro-audio

        ${pkgs.alsa-utils}/bin/amixer -c 2 set IEC958 on

        for _ in $(seq 1 20); do
          if ${pkgs.pulseaudio}/bin/pactl list short sinks \
            | grep -q 'alsa_output.pci-0000_00_1f.3.pro-output-1'; then
            break
          fi
          sleep 0.1
        done

        ${pkgs.pulseaudio}/bin/pactl set-sink-volume \
          alsa_output.pci-0000_00_1f.3.pro-output-1 30%
      '';
      RemainAfterExit = true;
    };

    Install.WantedBy = [ "default.target" ];
  };

  # Bide is intentionally not packaged yet.

  home.stateVersion = "26.05";
}
