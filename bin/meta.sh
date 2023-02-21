#!/bin/bash

# KDE Plasma Applets Developer Tools
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2020-2023 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/plasmoid-tools
#
# Creates <PLASMOID_ROOT>/contents/js/meta.js file with plasmoid metadata.
#

set -euo pipefail

# shellcheck disable=SC2155
declare -r ROOT_DIR="$(realpath "$(dirname "$(realpath "${0}")")/..")"
source "${ROOT_DIR}/bin/common.sh"

declare -r meta_file="${PLASMOID_ROOT}/contents/js/meta.js"
mkdir -p "$(dirname "${meta_file}")"
dumpMeta > "${meta_file}"

echo "Meta data file created: ${meta_file}"
