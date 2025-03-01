{
  description = "Nix Arcade ISO Generator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  # or use: nixos-23.05, or nixos-unstable, etc.

  outputs = { self, nixpkgs }:
  {
    nixosConfigurations.live = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Now this works because nixpkgs.path actually exists:
        "${nixpkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./additional-config.nix
      ];
    };
  };
}
