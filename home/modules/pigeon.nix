{ inputs, ... }:
{
  imports = [ inputs.pigeon.homeManagerModules.default ];

  # Pigeon starts from Hyprland's hyprland.start handler, like waybar and
  # swaync, because Hyprland without UWSM never reaches graphical-session.target.
  programs.pigeon = {
    enable = true;
    # Looks up website icons, which tells DuckDuckGo the domains that email me.
    settings.senderImages = true;
  };
}
