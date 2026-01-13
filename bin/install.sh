#!/bin/bash

# KDE Plasma Applets Developer Tools
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2020-2023 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/plasmoid-tools
#
# Packs plasmoid and installs/upgrades it locally (for your user), then restarts plasmashell.
#

set -euo pipefail

# shellcheck disable=SC2155
declare -r ROOT_DIR="$(realpath "$(dirname "$(realpath "${0}")")/..")"
source "${ROOT_DIR}/bin/common.sh"

function installPlasmoid() {
	local -r plasmoid_file_name="$(buildPlasmoidFileName)"

	local -r tmp="$(mktemp -d "/tmp/${plasmoid_file_name}.XXXXXX")"
	local -r target_plasmoid_file="$(mktemp -u "/tmp/${plasmoid_file_name}.plasmoid.XXXXXX")"
	cp -a "${PLASMOID_ROOT}"/* "${tmp}"

	dumpMeta > "${tmp}/contents/js/meta.js"

	pushd "${tmp}" > /dev/null
	zip  -r "${target_plasmoid_file}" -- *
	popd > /dev/null
	rm -rf "${tmp}"

	local -r pkg_name="$(getMetaTag "X-KDE-PluginInfo-Name")"
	local -r install_dir="${HOME}/.local/share/plasma/plasmoids/${pkg_name}"
	if kpackagetool6 -t Plasma/Applet --list | grep -q "^${pkg_name}$"; then
		kpackagetool6 -t Plasma/Applet --upgrade "${target_plasmoid_file}"
	else
		[[ -d "${install_dir}" ]] && rm -rf "${install_dir}"
		kpackagetool6 -t Plasma/Applet --install "${target_plasmoid_file}"
	fi

	kquitapp6 plasmashell
	kstart plasmashell

	rm -f "${target_plasmoid_file}"
}

installPlasmoid

