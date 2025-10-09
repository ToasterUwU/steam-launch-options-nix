import argparse
import json
import os

import vdf


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--user-id", required=False, default=None)
    parser.add_argument("--default-proton", required=False, default=None)
    parser.add_argument("--game-overrides", required=True)
    args = parser.parse_args()

    config_path = os.path.expanduser("~/.steam/steam/config/config.vdf")
    game_overrides = json.loads(args.game_overrides)

    if args.default_proton is not None:
        # Load existing VDF if exists
        if not os.path.exists(config_path):
            print(
                f"VDF file {config_path} does not exist, meaning Steam has never been run. Skipping."
            )
        else:
            with open(config_path, "r") as f:
                data = vdf.load(f)

            data["InstallConfigStore"]["Software"]["Valve"]["Steam"].setdefault(
                "CompatToolMapping", {}
            )
            data["InstallConfigStore"]["Software"]["Valve"]["Steam"][
                "CompatToolMapping"
            ]["0"] = {"name": args.default_proton, "config": "", "priority": "75"}

            # Write back modified VDF
            with open(config_path, "w") as f:
                vdf.dump(data, f, pretty=True)

    # Load existing VDF if exists
    if not os.path.exists(config_path):
        print(
            f"VDF file {config_path} does not exist, meaning Steam has never been run. Skipping."
        )
    else:
        with open(config_path, "r") as f:
            data = vdf.load(f)

        compat_tool_mapping = {}
        for app_id, opts in game_overrides.items():
            if opts["protonOverride"] is not None:
                compat_tool_mapping[app_id] = {
                    "name": opts["protonOverride"],
                    "config": "",
                    "priority": "250",
                }

        data["InstallConfigStore"]["Software"]["Valve"]["Steam"].setdefault(
            "CompatToolMapping", {}
        )
        data["InstallConfigStore"]["Software"]["Valve"]["Steam"][
            "CompatToolMapping"
        ].update(compat_tool_mapping)

        # Write back modified VDF
        with open(config_path, "w") as f:
            vdf.dump(data, f, pretty=True)

    if args.user_id is None:
        steam_user_ids = [
            d
            for d in os.listdir(os.path.expanduser("~/.steam/steam/userdata"))
            if d.isdigit()
        ]
    else:
        steam_user_ids = [args.user_id]

    for user_id in steam_user_ids:
        localconfig_path = os.path.expanduser(
            f"~/.steam/steam/userdata/{user_id}/config/localconfig.vdf"
        )

        # Load existing VDF if exists
        if os.path.exists(localconfig_path):
            with open(localconfig_path, "r") as f:
                data = vdf.load(f)
        else:
            print(
                f"VDF file {localconfig_path} does not exist, meaning Steam has never been run for this user. Skipping."
            )
            continue  # Stop processing if VDF doesn't exist

        # Merge launch options
        apps = data["UserLocalConfigStore"]["Software"]["Valve"]["Steam"].setdefault(
            "apps", {}
        )
        for app_id, opts in game_overrides.items():
            if opts["launchOptions"] is None:
                continue  # Skip if no launch options to set

            app_entry = apps.setdefault(app_id, {})
            app_entry["LaunchOptions"] = opts["launchOptions"]

        # Write back modified VDF
        with open(localconfig_path, "w") as f:
            vdf.dump(data, f, pretty=True)


if __name__ == "__main__":
    main()
