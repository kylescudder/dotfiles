{ config, lib, pkgs, inputs, username, hostname, ... }:
{
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # UK locale/timezone.
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.xkb.layout = "gb";

  # Flakes are the entry point for this configuration.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # The Arch bootstrap installs several unfree applications/drivers.
  nixpkgs.config.allowUnfree = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Kyle Scudder";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # Desktop: preserve GNOME + GDM as well as Hyprland.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.hyprland.enable = true;

  # PipeWire gives both GNOME and Hyprland a consistent audio stack.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # NVIDIA: the Arch script explicitly installs nvidia-open.
  # This is correct for Turing/GTX 16/RTX 20 and newer. If this machine has an
  # older NVIDIA GPU, set hardware.nvidia.open = false before the first build.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Steam's NixOS module includes the system integration and 32-bit support
  # that the Arch script obtains via steam + lib32-nvidia-utils.
  programs.steam.enable = true;

  # Xbox wireless controller driver. Firmware is managed by the NixOS module
  # rather than a DKMS clone/install script.
  hardware.xone.enable = true;

  # Tailscale is installed and starts at boot. Authenticate once with
  # `sudo tailscale login` after installation; no auth secret is stored here.
  services.tailscale.enable = true;

  # 1Password CLI + GUI with the privileged integration NixOS requires.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ username ];
  };

  # The old bootstrap manually clones Catppuccin's GRUB theme. The module owns
  # it declaratively. The hardware file should choose/enable the actual loader.
  catppuccin.grub = {
    enable = true;
    flavor = "mocha";
  };

  # Packages which are genuinely system-level rather than user dotfile tools.
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    unzip
    jq
    fuse
  ];

  # Do not change this casually after installation. It records the NixOS
  # compatibility baseline, not the NixOS release you are currently running.
  system.stateVersion = "26.05";
}
