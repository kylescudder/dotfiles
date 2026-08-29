{ lib, ... }:

{
  networking.hostName = lib.mkForce "nixos-vm";

  # The VM doesn't use the physical workstation's bootloader.
  boot.loader.grub.enable = lib.mkForce false;

  # Don't try to configure the RTX 3080 inside QEMU.
  services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];

  hardware.nvidia = {
    modesetting.enable = lib.mkForce false;
    open = lib.mkForce false;
    nvidiaSettings = lib.mkForce false;
  };

  # No physical Xbox controller driver needed in the VM.
  hardware.xone.enable = lib.mkForce false;

  users.users.kyle = {
    isNormalUser = true;
    initialPassword = "test";

    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  virtualisation.vmVariant.virtualisation = {
    memorySize = 8192;
    cores = 4;
    diskSize = 30000;
  };
}
