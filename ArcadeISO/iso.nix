{ config, pkgs, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ./config.nix
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

}
