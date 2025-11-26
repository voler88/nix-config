{
  description = "NixOS configurations.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      nixos-facter-modules,
    }:
    let
      fmtSystems = [ "x86_64-linux" ];
      machines = builtins.attrNames (
        nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./machines)
      );
    in
    {
      formatter = nixpkgs.lib.genAttrs fmtSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
      nixosConfigurations = nixpkgs.lib.genAttrs machines (
        machine:
        nixpkgs.lib.nixosSystem {
          modules = [
            disko.nixosModules.disko
            nixos-facter-modules.nixosModules.facter
            ./machines/${machine}
            {
              config.facter.reportPath = ./machines/${machine}/facter.json;
              networking.hostName = machine;
              system.stateVersion = "25.05";
            }
          ];
        }
      );
    };
}
