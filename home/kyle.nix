{ username, ... }:
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
    ./modules/yap.nix
    ./modules/apps.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Bide is intentionally not packaged yet.

  home.stateVersion = "26.05";
}
