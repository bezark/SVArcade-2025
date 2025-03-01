{ config, pkgs, lib, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    ./config.nix
  ];

  # Let your config's "networkmanager.enable" setting win:
  networking.networkmanager.enable = lib.mkForce true;


  # If you had "networking.wireless.enable = true" or something that conflicts, disable it:
  networking.wireless.enable = lib.mkForce false;

  # Optionally, ensure it boots on EFI, etc.
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
}
