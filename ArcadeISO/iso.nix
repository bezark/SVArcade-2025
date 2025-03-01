{ config, pkgs, lib, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    ./configuration.nix
  ];

  # Let your config's "networkmanager.enable" setting win:
  networking.networkmanager.enable = lib.mkForce true;

  # If your config sets "networking.interfaces" for enp6s0/wlp5s0,
  # but the minimal ISO also sets them in a conflicting way, forcibly empty them:
  networking.interfaces = lib.mkForce { };

  # If you had "networking.wireless.enable = true" or something that conflicts, disable it:
  # networking.wireless.enable = lib.mkForce false;

  # Optionally, ensure it boots on EFI, etc.
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
}
