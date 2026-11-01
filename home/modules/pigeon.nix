{ inputs, ... }:
let
  # Zoho EU, with implicit TLS on 993 and 465. Passwords (app-specific ones
  # when two-factor sign-in is on) go into the keyring from Pigeon, not here.
  zoho = address: realName: {
    inherit address realName;
    userName = address;
    imap = {
      host = "imappro.zoho.eu";
      tls.enable = true;
    };
    smtp = {
      host = "smtppro.zoho.eu";
      tls.enable = true;
    };
    pigeon.enable = true;
  };
in
{
  imports = [ inputs.pigeon.homeManagerModules.default ];

  # Pigeon starts from Hyprland's hyprland.start handler, like waybar and
  # swaync, because Hyprland without UWSM never reaches graphical-session.target.
  programs.pigeon = {
    enable = true;
    # Looks up website icons, which tells DuckDuckGo the domains that email me.
    settings.senderImages = true;
  };

  accounts.email.accounts = {
    kylescudder = zoho "kyle@kylescudder.co.uk" "Kyle Scudder" // {
      primary = true;
    };
    thescudders = zoho "kyle@thescudders.org" "Kyle Scudder";
    rhiannandkyle = zoho "rhiannandkyle@thescudders.org" "Rhiann and Kyle Scudder";
  };
}
