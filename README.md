## Set Steam Game Launch Options via Nix

Im trying to close the gaps of the few things i cant just put into a nix config and have set declaritively. This was one of the biggest ones for me.
Its my first home-manager module ever, so expect this to be unstable and weird.

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

And then use that to import the module in home-manager via the "sharedModules" key. At the time of writing this my flake (which is also a public repo) uses it like this:
```nix
home-manager = {
  sharedModules = [ inputs.steam-launch-options.homeManagerModules.steam-launch-options ];
  users.aki = {
    programs.steam-launch-options = {
      enable = true;
      userId = "149816402";
      launchOptions = {
        "359320" =
          "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc OXR_PARALLEL_VIEWS=1 MinEdLauncher %command% /autorun /autoquit /edo /vr /restart 15"; # Elite Dangerous
        "2519830" =
          "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc OXR_PARALLEL_VIEWS=1 %command% -LoadAssembly Libraries/ResoniteModLoader.dll"; # Resonite
        "438100" = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%"; # VRChat
        "1292040" = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%"; # Stride
        "620980" = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%"; # Beat Saber
        "2441700" = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%"; # UNDERDOGS
        "1755100" = "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%"; # The Last Clockwinder
        "1225570" =
          "for var in $(printenv | awk -F= 'length($2) > 2000 {print $1}'); do export $var=$(echo \${!var} | rev | cut -c 1-2000 | rev); done ; %command%"; # Unravel Two, EA Launcher Fix
        "1233570" =
          "for var in $(printenv | awk -F= 'length($2) > 2000 {print $1}'); do export $var=$(echo \${!var} | rev | cut -c 1-2000 | rev); done ; %command%"; # Mirror's Edge Catalyst, EA Launcher Fix
      };
    };
  };
};
```

For this to work you need to have steam installed, have started it once so that it downloads the actual .steam directory stuff, login with your account, and then you need to set the options like above.
The Options:
1. "enable": does what it says, the other settings wont take affect if this isnt set to true
2. "userId": This is the ID your Steam user has. It seems to be different from the userId that is used by API stuff, so make sure you use the correct one. It can be found as the folder name within "~/.steam/steam/userdata/"
3. "launchOptions": This is the ID of the steam game as the key, and the launch options you would normally paste into the steam game properties as the value. You can find the Game ID via tools like "SteamDB" or by just opening the store page for the game and looking at the URL it shows. So for example, if the store page URL for the game is "https://store.steampowered.com/app/1593310/NEKOPARA__Catboys_Paradise/", then the ID you need to use as the Key is "1593310"

I never had the chance to test what happens when using this before having steam installed and being logged in, but the logic is there to handle this. It should in theory just make a file with the options, steam might add its own things fine, or it could think its a broken config file and delete and make its own. Either way, nothing should be able to break because of this. If you have a chance to test this, i would love to hear from you about your experience.