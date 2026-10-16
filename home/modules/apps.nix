{ pkgs, ... }:

{
  programs.thunderbird.enable = true;

  home.packages = with pkgs; [
    obsidian
    whatsie # Unofficial WhatsApp Web desktop client.
  ];
}
