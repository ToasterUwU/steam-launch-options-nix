{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.steam-launch-options;

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ vdf ]);

  mergerScript = pkgs.writeScript "steam-launch-options-merger.py" ''
    #!${pythonEnv}/bin/python3
    ${builtins.readFile ../assets/steam-launch-options-inserter.py}
  '';
in
{
  options.programs.steam-launch-options = {
    enable = lib.mkEnableOption "Steam launch options management";

    userId = lib.mkOption {
      type = lib.types.str;
      example = "12345678";
      description = ''
        Your Steam user ID found as the folder name in ~/.steam/steam/userdata/ (No multiuser support atm)
      '';
    };

    launchOptions = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "730" = "-novid -console";
        "440" = "-windowed -noborder";
      };
      description = ''
        Attribute set where keys are Steam AppIDs and values are launch options
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.python3.withPackages (ps: [ ps.vdf ])) ];

    home.activation.steamLaunchOptions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pythonEnv}/bin/python3 ${mergerScript} \
        --user-id "${cfg.userId}" \
        --launch-options ${lib.escapeShellArg (builtins.toJSON cfg.launchOptions)}
    '';
  };
}
