{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.services.nordvpn;
  nordvpnPackage =
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nordvpn;

  nordvpn =
    let
      cli = nordvpnPackage.cli.overrideAttrs (old: {
        preBuild = (old.preBuild or "");
        postFixup = "";
      });
    in
    pkgs.symlinkJoin {
      inherit (nordvpnPackage) pname version meta;
      paths = [
        cli
        nordvpnPackage.gui
      ];
    };
in
{
  options.services.nordvpn.enable = lib.mkEnableOption "NordVPN";

  config = lib.mkIf cfg.enable {
    users.users.nordvpn = {
      description = "User that runs nordvpnd";
      group = "nordvpn";
      isSystemUser = true;
    };
    users.groups.nordvpn = { };

    services.resolved.enable = true;

    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.resolve1.set-dns-servers"
              && subject.isInGroup("nordvpn")) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    environment.systemPackages = [ nordvpn ];

    systemd.services.nordvpnd = {
      after = [ "network-online.target" ];
      description = "NordVPN daemon";
      path =
        (with pkgs; [
          e2fsprogs
          iproute2
          libxslt
          nftables
          procps
          wireguard-tools
        ])
        ++ [ nordvpn ];
      serviceConfig = {
        AmbientCapabilities = "CAP_NET_ADMIN";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        ExecStart = lib.getExe' nordvpn "nordvpnd";
        Group = "nordvpn";
        KillMode = "process";
        NonBlocking = true;
        Requires = "nordvpnd.socket";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "nordvpn";
        RuntimeDirectoryMode = "0750";
        StateDirectory = "nordvpn";
        StateDirectoryMode = "0750";
        User = "nordvpn";
      };
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.sockets.nordvpnd = {
      description = "NordVPN daemon socket";
      listenStreams = [ "/run/nordvpn/nordvpnd.sock" ];
      partOf = [ "nordvpnd.service" ];
      socketConfig = {
        DirectoryMode = "0750";
        NoDelay = true;
        SocketGroup = "nordvpn";
        SocketMode = "0770";
        SocketUser = "nordvpn";
      };
      wantedBy = [ "sockets.target" ];
    };

    # Tailscale marks its transport/control-plane traffic with 0x80000. Its
    # own policy rules normally send that traffic directly through the main
    # routing table, which NordVPN's firewall then rejects while connected.
    # Route that marked underlay traffic through NordVPN's table first. If
    # table 205 has no route (for example while disconnected), policy routing
    # simply falls through to Tailscale's normal rules.
    systemd.services.tailscale-via-nordvpn = {
      description = "Route Tailscale transport through NordVPN";
      before = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.iproute2}/bin/ip rule del priority 5200 fwmark 0x80000/0xff0000 lookup 205 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule add priority 5200 fwmark 0x80000/0xff0000 lookup 205
      '';
      preStop = ''
        ${pkgs.iproute2}/bin/ip rule del priority 5200 fwmark 0x80000/0xff0000 lookup 205 2>/dev/null || true
      '';
    };

    systemd.user.services.norduserd = {
      after = [ "network-online.target" ];
      description = "NordUserD service";
      serviceConfig = {
        ExecStart = lib.getExe' nordvpn "norduserd";
        NonBlocking = true;
        Restart = "on-failure";
        RestartSec = 5;
      };
      wantedBy = [ "graphical-session.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
