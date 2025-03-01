{
  description = "Nix Arcade ISO Generator";

  # Switch to a flake-based nixpkgs release, e.g. nixos-22.11:
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }:
  {
    nixosConfigurations.live =
      nixpkgs.nixosSystem {
        system = "x86_64-linux";

        # 'nixosModules.installer.cd-dvd.installation-cd-minimal'
        # is a flake-provided module for building a minimal ISO
        modules = [
          nixpkgs.nixosModules.installer.cd-dvd.installation-cd-minimal
          ./additional-config.nix
        ];
      };
  };
}
