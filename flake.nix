{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      devShells = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixfmt-rfc-style
            nil
            python3
            python3Packages.vdf
          ];
        };
      };

      homeManagerModules.steam-launch-options =
        { ... }:
        {
          imports = [ ./modules ];
        };
    };
}
