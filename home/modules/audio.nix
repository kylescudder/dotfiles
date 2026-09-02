{ pkgs, ... }:

{
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
}
