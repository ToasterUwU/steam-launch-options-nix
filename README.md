I found a project slightly younger than this one, but more actively maintained with better syntax and more features. I will be switching to it and stop maintaning this. So i recommend you switch as well.

https://github.com/different-name/steam-config-nix

<details>
  <summary>Click here for actual README</summary>
  ## Set Steam Game Launch Options via Nix

  Im trying to close the gaps of the few things i cant just put into a nix config and have set declaritively. This was one of the biggest ones for me.
  Its my first home-manager module ever, so expect this to be unstable and weird.

Im happy to fix issues if found, so feel free to make Issues if you find something, or even a PR if you feel like it.
  Im happy to fix issues if found, so feel free to make Issues if you find something, or even a PR if you feel like it.

  Im not planning on adding anything to this for now, but i might add setting a specific Proton version if i feel like this would be good to have. Currently i have no games that require that.

  ### Supported setups

  I made this mainly for me, so i made this x86_64 linux only for now, i dont have an ARM or especially Darwin system, so if you do feel free to make a PR to add support and test it.

  ### Installation and Usage

  This is installed like any other home-manager module that is a flake.

  So in your flake.nix inputs add something like this:
  ```nix
  inputs = {
    steam-launch-options = {
      url = "github:ToasterUwU/steam-launch-options-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  ```

  And then use that to import the module in home-manager via the "sharedModules" key. Here is an example usage from my own nixos config:
  ```nix
  home-manager = {
    sharedModules = [ inputs.steam-launch-options.homeManagerModules.steam-launch-options ];
    users.aki = {
      programs.steam-launch-options = {
        enable = true;
        userId = "149816402"; # I dont actually have this is my own config. Not setting this just means it applies to all steam users logged in under the linux user aki. Which is only me anyways.
        defaultProton = "GE-Proton";
        gameOverrides = {
          "359320" = {
            # Elite Dangerous
            launchOptions = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc OXR_PARALLEL_VIEWS=1 VR_OVERRIDE=${pkgs.opencomposite}/lib/opencomposite MinEdLauncher %command% /autorun /autoquit /edo /vr /restart 15";
          };
          "2519830" = {
            # Resonite
            launchOptions = "env -u TZ PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc OXR_PARALLEL_VIEWS=1 ./run_monkeyloader.sh %command%";
            protonOverride = "GE-Proton-rtsp";
          };
          "438100" = {
            # VRChat
            launchOptions = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%";
            protonOverride = "GE-Proton-rtsp";
          };
          "1292040" = {
            # Stride
            launchOptions = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%";
          };
          "620980" = {
            # Beat Saber
            launchOptions = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%";
          };
          "2441700" = {
            # UNDERDOGS
            launchOptions = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%";
          };
          "1755100" = {
            # The Last Clockwinder
            launchOptions = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%";
          };
          "1225570" = {
            # Unravel Two, EA Launcher Fix
            launchOptions = "for var in $(printenv | awk -F= 'length($2) > 2000 {print $1}'); do export $var=$(echo \${!var} | rev | cut -c 1-2000 | rev); done ; %command%";
          };
          "1233570" = {
            # Mirror's Edge Catalyst, EA Launcher Fix
            launchOptions = "for var in $(printenv | awk -F= 'length($2) > 2000 {print $1}'); do export $var=$(echo \${!var} | rev | cut -c 1-2000 | rev); done ; %command%";
            protonOverride = "proton_8";
          };
          "1238080" = {
            # Burnout Paradise Remastered, EA Launcher Fix
            launchOptions = "for var in $(printenv | awk -F= 'length($2) > 2000 {print $1}'); do export $var=$(echo \${!var} | rev | cut -c 1-2000 | rev); done ; %command%";
          };
          "450540" = {
            # H3VR
            launchOptions = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%";
          };
          "244850" = {
            # Space Engineers
            launchOptions = "%command% -useallavailablecores";
          };
        };
      };
    };
  };
  ```

  For this to work you need to have steam installed, have started it once so that it downloads the actual .steam directory stuff, login with your account, and then you need to set the options like above. If you dont have steam installed, or never ran it, or never logged in, these changes simply wont take affect, nothing should break or behave weirdly.
  The Options:
  1. "enable": does what it says, the other settings wont take affect if this isnt set to true
  2. "userId": This is optional, if not set it will apply to all logged in users. This is the ID your Steam user has. It seems to be different from the userId that is used by API stuff, so make sure you use the correct one. It can be found as the folder name within "~/.steam/steam/userdata/"
  3. "defaultProton": This is optional, if not set Steam seems to default to Proton Experimental. This is the setting you can find in the steam client settings under "compatibility". It defines what proton version to use if no other one is defined on a per game basis.
  4. "gameOverrides": This is the ID of the steam game as the key, and a set of the launch options you would normally paste into the steam game properties and a specific proton version as the values. You can find the Game ID via tools like "SteamDB" or by just opening the store page for the game and looking at the URL it shows. So for example, if the store page URL for the game is "https://store.steampowered.com/app/1593310/NEKOPARA__Catboys_Paradise/", then the ID you need to use as the Key is "1593310"

  If you are unsure how to use the options, check out the example above, it uses each thing besides the userid at least once.
  Something worth noting is that the official version of proton show differently in the Steam UI than in the config file. So for example "Proton 9" in the UI, "proton_9" in the config. For custom extra versions of Proton like GE this doesnt seem to apply, it just what you see in the UI.
</details>