import argparse
import json
import os

import vdf


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--user-id", required=True)
    parser.add_argument("--launch-options", required=True)
    args = parser.parse_args()

    vdf_path = os.path.expanduser(
        f"~/.steam/steam/userdata/{args.user_id}/config/localconfig.vdf"
    )
    launch_opts = json.loads(args.launch_options)

    # Load existing VDF if exists
    if os.path.exists(vdf_path):
        with open(vdf_path, "r") as f:
            data = vdf.load(f)
    else:
        data = {"UserLocalConfigStore": {"Software": {"Valve": {"Steam": {}}}}}

    # Merge launch options
    apps = data["UserLocalConfigStore"]["Software"]["Valve"]["Steam"].setdefault(
        "apps", {}
    )
    for app_id, opts in launch_opts.items():
        app_entry = apps.setdefault(app_id, {})
        app_entry["LaunchOptions"] = opts

    # Write back modified VDF
    os.makedirs(os.path.dirname(vdf_path), exist_ok=True)
    with open(vdf_path, "w") as f:
        vdf.dump(data, f, pretty=True)


if __name__ == "__main__":
    main()
