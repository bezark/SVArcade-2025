{

  description = "Nix Arcade ISO Generator";
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
  
  outputs = { self, nixpkgs }: {
    nixosConfigurations.live = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./additional-config.nix
      ];
    };
  };
}
