#!/bin/bash

BASE_DIR="$(dirname "$(realpath "$0")")/..";
CURRENT_DIR="$(pwd)"

echo "Uploading to dev server..."

"${BASE_DIR}/scripts/compile.sh"
echo ""
"${BASE_DIR}/scripts/pack.sh"
echo ""

echo "Uploading to server..."
source "$BASE_DIR/scripts/dev.ftp"
cd "${BASE_DIR}/out/csgotailor"

if [[ $1 == "--smx" ]]; then
  curl -s -u "${USERNAME}:${PASSWORD}" --ftp-create-dirs -T addons/sourcemod/plugins/csgotailor.smx "ftp://${HOST}/addons/sourcemod/plugins/csgotailor.smx"
else
  find . -type f -exec curl -s -u "${USERNAME}:${PASSWORD}" --ftp-create-dirs -T {} "ftp://${HOST}/{}" \;
fi

echo "Uploaded to '${HOST}'."

cd $CURRENT_DIR
