{ pkgs, username, ... }:
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
    ./modules/desktop.nix
    ./modules/media.nix
    ./modules/gaming.nix
    ./modules/fonts.nix
    ./modules/custom-tools.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    # Audio utilities used by the workstation audio setup and switch scripts.
    pulseaudio
    alsa-utils

    # Desktop applications not yet split into their own module.
    obsidian
    thunderbird
  ];

  # Bide is intentionally not packaged yet.

  home.stateVersion = "26.05";
}
