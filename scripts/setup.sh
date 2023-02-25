#!/bin/bash

BASE_DIR="$(dirname "$(realpath "$0")")/.."
CURRENT_DIR="$(pwd)"

echo "Setting up development environment"
echo ""

rm -rf "${BASE_DIR}/build"
mkdir "${BASE_DIR}/build"

sourcemod_download_prefix="https://sm.alliedmods.net/smdrop/1.11/"
sourcemod_latest=$(wget ${sourcemod_download_prefix}sourcemod-latest-linux -q -O -)

echo "Downloading ${sourcemod_latest}..."
wget -q -O "${BASE_DIR}/build/sourcemod.tar.gz" "${sourcemod_download_prefix}${sourcemod_latest}"
echo "Downloaded to 'build/sourcemod.tar.gz'"

echo ""

echo "Extracting sourcemod..."
mkdir "${BASE_DIR}/build/sourcemod"
tar -xzf "${BASE_DIR}/build/sourcemod.tar.gz" -C "${BASE_DIR}/build/sourcemod"
echo "Extracted to 'build/sourcemod/'"

echo ""

echo "Downloading dependencies..."
echo "  Getting PHaT..."
git clone --quiet https://github.com/komashchenko/PTaH.git "${BASE_DIR}/build/PTaH"
cp "${BASE_DIR}/build/PTaH/PTaH.inc" "${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/include/"

echo "  Getting sm-json..."
git clone --quiet https://github.com/clugg/sm-json.git "${BASE_DIR}/build/sm-json"
cp -r "${BASE_DIR}/build/sm-json/addons/sourcemod/scripting/include/." "${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/include/"

echo "  Getting SourceScramble..."
git clone --quiet https://github.com/nosoop/SMExt-SourceScramble.git "${BASE_DIR}/build/SourceScramble"
cp -r "${BASE_DIR}/build/SourceScramble/scripting/include/." "${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/include/"

echo "Dependencies downloaded."

echo ""

echo "Fetching game files for generator..."
wget -q -O "${BASE_DIR}/generator/items_game.txt" "https://raw.githubusercontent.com/SteamDatabase/GameTracking-CSGO/master/csgo/scripts/items/items_game.txt"
wget -q -O "${BASE_DIR}/generator/csgo_english.txt" "https://raw.githubusercontent.com/SteamDatabase/GameTracking-CSGO/master/csgo/resource/csgo_english.txt"
echo "Game files downloaded. (items_game.txt, csgo_english.txt)"

echo "Setting up generator..."
cd "${BASE_DIR}/generator"
yarn install >> /dev/null
echo "Generator dependencies installed."
echo "Creating fresh data.json file...";
yarn generate >> /dev/null
cp "${BASE_DIR}/generator/out/data.json" "${BASE_DIR}/plugin/data/csgotailor/data.json"
echo "Fresh data.json created (generator/out/data.json)"

echo ""
echo "Setup complete."

cd $CURRENT_DIR
