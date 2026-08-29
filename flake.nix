{
  description = "Kyle's NixOS workstation configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr-src = {
      url = "github:kylescudder/herdr";
      flake = false;
    };

    hyprland-guiutils = {
      url = "github:hyprwm/hyprland-guiutils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    nixpkgs,
    home-manager,
    catppuccin,
    ...
  }:
    let
      system = "x86_64-linux";
      username = "kyle";

      homeManagerModule = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;

          extraSpecialArgs = {
            inherit inputs username;
          };

          sharedModules = [
            catppuccin.homeModules.catppuccin
          ];

          users.${username} = import ./home/kyle.nix;
        };
      };

      commonModules = [
        ./nixos/hosts/workstation/configuration.nix

        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager

        homeManagerModule
      ];
    in {
      nixosConfigurations = {

        # Real workstation
        stevie = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs username;
            hostname = "stevie";
          };

          modules =
            commonModules
            ++ [
              ./nixos/hosts/workstation/hardware-configuration.nix
            ];
        };

        # Disposable QEMU test VM
        vm = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs username;
            hostname = "nixos-vm";
          };

          modules =
            commonModules
            ++ [
              ./nixos/hosts/vm/configuration.nix
            ];
        };
      };
    };
}
