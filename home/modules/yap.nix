{ pkgs, inputs, ... }:
let
  yap = inputs.yap.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  systemd.user.services = {
    yap = {
      Unit = {
        Description = "Yap local voice dictation";
        After = [ "graphical-session.target" "pipewire.service" ];
      };

      Service = {
        Type = "dbus";
        BusName = "com.yap.Yap";
        ExecStart = "${yap}/bin/yapd";
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    yap-overlay = {
      Unit = {
        Description = "Yap dictation status overlay";
        After = [ "graphical-session.target" "yap.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${yap}/bin/yap-overlay";
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    yap-tray = {
      Unit = {
        Description = "Yap desktop status indicator";
        After = [ "graphical-session.target" "yap.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${yap}/bin/yap-tray";
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
