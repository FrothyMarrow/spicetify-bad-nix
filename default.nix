{
  inputs,
  pkgs,
  lib,
}: 
let
  generator = import ./lib/generator.nix { inherit lib; };

  configINI = generator.toConfigXpui {
    colorScheme = "mocha";
    currentTheme = "catppuccin";
  };
in 
{
  spotify = generator.spicedSpotify {
    inherit (pkgs) spotify;
    inherit (pkgs) spicetify-cli;
    inherit (pkgs) coreutils-full;
    inherit configINI;
    inherit (inputs) catppuccin;
  };
}