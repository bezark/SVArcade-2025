{
  description = "Nix Arcade ISO Generator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }:
    {
      nixosConfigurations.live = let
        # "legacyPackages.x86_64-linux" is the normal package set for x86_64
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in pkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          # Pull in the minimal ISO module directly from nixpkgs' flake:
          pkgs.nixosModules.installer.cd-dvd.installation-cd-minimal

          # Your own config file
          ./additional-config.nix
        ];
      };
    };
}
