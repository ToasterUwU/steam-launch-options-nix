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
    ${builtins.readFile ../scripts/steam-launch-options-inserter.py}
  '';
in
{
  options.programs.steam-launch-options = {
    enable = lib.mkEnableOption "Steam launch options management";

    userId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "12345678";
      description = ''
        Your Steam user ID found as the folder name in ~/.steam/steam/userdata/
        If not set or explicitly set to null, this will apply to every single logged in steam user.
        Because of the way Steam stores its configuration, this has no effect on proton overrides, which are always for all users.
      '';
    };

    launchOptions = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
      default = null;
      example = {
        "730" = "-novid -console";
        "440" = "-windowed -noborder";
      };
      description = ''
        Attribute set where keys are Steam AppIDs and values are launch options
      '';
    };

    defaultProton = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "GE-Proton9-22";
      description = ''
        Default Proton compatibility layer override to apply to all games, can be overridden per-game in gameOverrides.
        Leave empty to not set a default Proton override.
        This is the same as setting the default Proton version in the Steam client settings.
      '';
    };

    gameOverrides = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf (lib.types.attrsOf lib.types.str));
      default = { };
      example = {
        "730" = {
          launchOptions = "-novid -console";
          protonOverride = "GE-Proton9-22";
        };
      };
      description = ''
        Attribute set where keys are Steam AppIDs and values are attribute sets which contain the launch options and Proton overrides.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    warnings = [
      "Thanks for using this module! However, someone else started a similar project about to 2 months after mine, they added more options, they have a nicer syntax, and they are actively maintaining it. I will not be maintaining this module anymore, please consider switching to https://github.com/different-name/steam-config-nix"
    ];

    home.activation.steamLaunchOptions =
      let
        # Normalized view of `gameOverrides` where each game's inner attrs
        # always contain both keys and missing values are set to null. This
        # is useful for downstream code that expects both fields to exist.
        #
        # Migration: if the user is still using the deprecated `launchOptions`
        # and `gameOverrides` is empty, convert `launchOptions` into the new
        # per-game shape so users keep their settings during upgrade.
        normalizedGameOverrides =
          let
            # Source can be either the new `gameOverrides` or, if that's empty,
            # the deprecated `launchOptions` (which maps AppID -> string).
            overridesSrc = if cfg.gameOverrides != { } then cfg.gameOverrides else (cfg.launchOptions or { });
          in
          builtins.mapAttrs (
            app: val:
            let
              # If the value is already an attrset, use it. Otherwise treat it as
              # the old string-style launchOptions and wrap it into an attrset.
              attrs =
                if lib.isAttrs val then
                  val
                else
                  {
                    launchOptions = val;
                    protonOverride = null;
                  };
            in
            {
              launchOptions = attrs.launchOptions or null;
              protonOverride = attrs.protonOverride or null;
            }
          ) overridesSrc;
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pythonEnv}/bin/python3 ${mergerScript} \
          --user-id ${lib.escapeShellArg cfg.userId} \
          --default-proton ${lib.escapeShellArg cfg.defaultProton} \
          --game-overrides ${lib.escapeShellArg (builtins.toJSON normalizedGameOverrides)}
      '';
  };
}
