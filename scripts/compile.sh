#!/bin/bash

BASE_DIR="$(dirname "$(realpath "$0")")/.."
VERSION="$(cat "${BASE_DIR}/VERSION")"

cp -r "${BASE_DIR}/plugin/." "${BASE_DIR}/build/sourcemod/addons/sourcemod/"

sed -i "s/{{VERSION}}/${VERSION}/" "${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/csgotailor/version.sp"

rm -rf "${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/compiled"
mkdir "${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/compiled"
"${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/spcomp64" "${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/csgotailor.sp" -o"${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/compiled/csgotailor.smx"
