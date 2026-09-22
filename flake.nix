{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-26.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    sops-nix.url = "github:Mic92/sops-nix";
#    nix-index-database = {
#      url = "github:nix-community/nix-index-database";
#      inputs.nixpkgs.follows = "nixpkgs";
#    }; 
 };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.melchior = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
 #   	inputs.nix-index-database.homeModules.nix-index
 # 	{
 #   	  programs.nix-index.enable = true;
 #   	  programs.nix-index-database.comma.enable = true; # Adds the "," shortcut command
 # 	}
      ];
    };
  };
}
