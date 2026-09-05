{ config, lib, pkgs, inputs, username, hostname, ... }:
{
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # UK locale/timezone.
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.xkb.layout = "gb";

  # UEFI bootloader. This board ignores custom NVRAM boot entries, so GRUB is
  # installed to the standard removable/fallback path EFI/BOOT/BOOTX64.EFI.
  boot.loader = {
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot";
    };

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      efiInstallAsRemovable = true;
    };
  };

  # Flakes are the entry point for this configuration.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Several workstation applications/drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Kyle Scudder";
    extraGroups = [ "wheel" "networkmanager" "nordvpn" ];
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

  # NVIDIA RTX 3080 (Ampere) using the open NVIDIA kernel modules.
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

  # Steam's NixOS module includes the system integration and 32-bit support.
  programs.steam.enable = true;

  # Xbox wireless controller driver.
  hardware.xone.enable = true;

  # Tailscale is installed and starts at boot. Authenticate once with
  # `sudo tailscale login` after installation; no auth secret is stored here.
  services.tailscale.enable = true;

  # NordVPN uses policy routing for the tunnel. NixOS' strict reverse-path
  # filtering drops that asymmetric VPN traffic, so use loose rpfilter mode.
  networking.firewall.checkReversePath = "loose";

  # NordVPN uses the locally adapted NixOS module, backed by the already-pinned
  # unstable nixpkgs package.
  services.nordvpn.enable = true;

  # 1Password CLI + GUI with the privileged integration NixOS requires.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ username ];
  };

  # Catppuccin theme for the GRUB bootloader configured above.
  catppuccin = {
    enable = true;
    autoEnable = false;

    grub = {
      enable = true;
      flavor = "mocha";
    };
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
