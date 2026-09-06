{ config, pkgs, inputs, ... }:

let
  cursorTheme = "catppuccin-mocha-mauve-cursors";
  cursorSize = 24;
  cursorThemeDirectory = ../../icons + "/${cursorTheme}";
in

assert builtins.pathExists (cursorThemeDirectory + "/cursors/left_ptr");
assert builtins.pathExists (cursorThemeDirectory + "/manifest.hl");

{
  programs.vesktop.enable = true;

  # Keep the compositor, GTK applications, and XWayland clients on the same
  # cursor theme. The theme itself is linked into XDG_DATA_HOME by dotfiles.nix.
  home.sessionVariables = {
    HYPRCURSOR_THEME = cursorTheme;
    HYPRCURSOR_SIZE = toString cursorSize;
    XCURSOR_THEME = cursorTheme;
    XCURSOR_SIZE = toString cursorSize;
  };

  home.sessionSearchVariables.XCURSOR_PATH = [
    "${config.home.homeDirectory}/.icons"
    "${config.home.homeDirectory}/.local/share/icons"
    "${config.home.profileDirectory}/share/icons"
    "/run/current-system/sw/share/icons"
    "/usr/share/icons"
  ];

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
    cursor-size = cursorSize;
    cursor-theme = cursorTheme;
    gtk-theme = "Adwaita-dark";
  };

  home.packages = with pkgs; [
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
  ];
}
