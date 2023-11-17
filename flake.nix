{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    catppuccin.url = "github:catppuccin/spicetify";
    catppuccin.flake = false;
  };
  
  outputs = { self, nixpkgs, catppuccin } @ inputs:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs { 
      inherit system; 
      config.allowUnfree = true;
    };
  in
  {
    defaultPackage.${system} = (import ./default.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit inputs;
    }).spotify;
  };
}