#!/bin/bash

# KDE Plasma Applets Developer Tools
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2020-2023 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/plasmoid-tools
#
# Packs plasmoid files for the release.
#

set -euo pipefail

# shellcheck disable=SC2155
declare -r ROOT_DIR="$(realpath "$(dirname "$(realpath "${0}")")/..")"
source "${ROOT_DIR}/bin/common.sh"

function releasePlasmoid() {
	local -r plasmoid_file_name="$(buildPlasmoidFileName)"
	local target_dir="$(pwd)"
	local -r rel_dir="${target_dir}/release"
	[[ -w "${rel_dir}" ]] && target_dir="${rel_dir}"

	local -r target_file="${rel_dir}/${plasmoid_file_name}"
	[[ -f "${target_file}" ]] && abort "File already exists: ${target_file}"

	local -r tmp="$(mktemp -d "/tmp/${plasmoid_file_name}.XXXXXX")"
	cp -a "${PLASMOID_ROOT}"/* "${tmp}"

	dumpMeta > "${tmp}/contents/js/meta.js"

	pushd "${tmp}" > /dev/null
	zip -q -r "${target_file}" -- *
	popd > /dev/null

	rm -rf "${tmp}"

	echo "Plasmoid archive saved: ${target_file}"
}

releasePlasmoid
