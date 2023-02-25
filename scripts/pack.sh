#!/bin/bash

BASE_DIR="$(dirname "$(realpath "$0")")/.."
VERSION="$(cat "${BASE_DIR}/VERSION")"

echo "Packing for release..."

rm -rf "${BASE_DIR}/out"

mkdir -p "${BASE_DIR}/out/csgotailor/addons/sourcemod/configs/"
mkdir -p "${BASE_DIR}/out/csgotailor/addons/sourcemod/plugins/"
mkdir -p "${BASE_DIR}/out/csgotailor/addons/sourcemod/scripting/"
mkdir -p "${BASE_DIR}/out/csgotailor/addons/sourcemod/translations/"
mkdir -p "${BASE_DIR}/out/csgotailor/cfg/sourcemod/"

cp -r "${BASE_DIR}/plugin/." "${BASE_DIR}/out/csgotailor/addons/sourcemod/"
cp "${BASE_DIR}/build/sourcemod/addons/sourcemod/scripting/compiled/csgotailor.smx" "${BASE_DIR}/out/csgotailor/addons/sourcemod/plugins/csgotailor.smx"

tar -zcf "${BASE_DIR}/out/csgotailor-${VERSION}.tar.gz" -C "${BASE_DIR}" README.md LICENSE -C "${BASE_DIR}/out/" csgotailor

echo "Packed for release (out/csgotailor-${VERSION}.tar.gz)"
