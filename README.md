# CSGO Tailor

## Description
Sourcemod plugin for CSGO allowing players to customize all of the following:
  - Weapons
    - Skins
    - Wear/float
    - Seed
    - StatTrak™
    - Nametag
    - Stickers
  - Knifes
    - Type
    - Skin
    - Wear/float
    - Seed
    - StatTrak™
    - Nametag
  - Gloves
    - Skins
    - Wear/float
    - Seed
  - Agent Skins
    - Patches
  - Spray/Graffiti
  - Profile
    - Pins
    - Matchmaking Rank
    - XP Level
    - Music Kit

You can also set different weapon skins per team and also different knifes and gloves per team too.

## Requirements
- [Sourcemod 1.11](https://www.sourcemod.net/downloads.php)
- [PTaH](https://github.com/komashchenko/PTaH)
- [Source Scramble](https://github.com/nosoop/SMExt-SourceScramble) (Windows Only)

## Installation
1. Grab the latest release from the release page and unzip it in to your sourcemod folder.
2. Add a new driver to your `database.cfg` file in `addons/sourcemod/configs/`.

```
"csgotailor"
{
  "driver"            "mysql"
  "host"              "..."
  "database"          "..."
  "user"              "..."
  "pass"              "..."
  "port"              "3306"
}
```

3. Restart the server.
4. The plugin convars config file will be automatically generated in `cfg/sourcemod/`.
5. You can also find the config and permissions file in `addons/sourcemod/configs/cgotailor/`.

## Development

#### Requirements to compile
- [Sourcemod 1.11](https://www.sourcemod.net/downloads.php)
- [sm-json](https://github.com/clugg/sm-json)
- [PTaH](https://github.com/komashchenko/PTaH)
- [Source Scramble](https://github.com/nosoop/SMExt-SourceScramble)

There is some scripts provided in the `scripts` directory to make setting up a dev environment easy. These scripts require a linux environment to function.

To start simply run the `scripts/setup.sh` script. This will download sourcemod and the plugin dependencies and generate a fresh `data.json` file. Once done you can then start to make changes inside the `plugin` directory. When you're done you can compile the plugin using the `scripts/compile.sh` script. Then to create a archive of the files to upload to your server you can use the `scripts/pack.sh` script.

If you want to make changes then upload to a dev server for testing you can use the `scripts/dev.sh` script which will compile, pack then upload via FTP to a server specified in the `scripts/dev.ftp` file. You can use the `scripts/example.dev.ftp` file as a template.
