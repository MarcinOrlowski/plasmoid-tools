#!/bin/bash

# KDE Plasma Applets Developer Tools
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2020-2021 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/plasmoid-tools
#
# Usage:
# ------
# # shellcheck disable=SC2155
# declare -r ROOT_DIR="$(realpath "$(dirname "$(realpath "${0}")")/..")"
# source "${ROOT_DIR}/bin/common.sh"
#

set -euo pipefail

# ----------------------------------------------------------

# Reads given tag from meta file. If tag is not present or empty returns
# ${default} (which is empty string if not provided).
#
# Arguments:
#        tag: tag to look for in metadata file
#    default: value to return if tag is not found or empty string
#  meta_file: path to metadata file (falls back to PLASMOID_ROOT located)
#
function getMetaTag() {
	local -r tag="${1:-}"
	local -r default="${2:-}"
	local -r meta_file="${3:-${PLASMOID_ROOT}/metadata.desktop}"
	
	echo "$(grep "^${tag}=" < "${meta_file}" | awk '{split($0,a,"="); print a[2]}')"
}

# ----------------------------------------------------------

# Echos some data from metadata.desktop file as JS code.
# This is to work around limitation of QML not exporting
# metadata unless post v5.76 of KDE QML framework.
#
function dumpMeta() {
	local -r pkg_version="$(getMetaTag "X-KDE-PluginInfo-Version")"
	local -r author_name="$(getMetaTag "X-KDE-PluginInfo-Author")"
	local -r author_url="$(getMetaTag "X-KDE-PluginInfo-Author-Url")"
	local -r project_name="$(getMetaTag "Name")"
	local -r project_url="$(getMetaTag "X-KDE-PluginInfo-Website")"
	local -r update_checker_url="$(getMetaTag "X-KDE-PluginInfo-UpdateChecker-Url")"
	local -r first_release_year="$(getMetaTag "X-KDE-PluginInfo-FirstReleaseYear")"

	if [[ -z "${first_release_year}" ]]; then
		first_release_year=1980
	fi

	echo -e \
"// This file is auto-generated. DO NOT EDIT BY HAND\n"\
"var version=\"${pkg_version}\"\n"\
"var title=\"${project_name}\"\n"\
"var url=\"${project_url}\"\n"\
"var authorName=\"${author_name}\"\n"\
"var authorUrl=\"${author_url}\"\n"\
"var updateCheckerUrl=\"${update_checker_url}\"\n"\
"var firstReleaseYear=${first_release_year}\n"

}

# ----------------------------------------------------------

# Looks for a plasmoid valid root folder. Starts from ${dir}
# then goes up untill root folder is reached.
#
# Note: by convention used, it first looks for "src/" folder
# in given folder, then checks if it contains metadata.desktop
# file. If it does, this is our valid root folder.
#
# Arguments:
#  dir: path to start from. Usually $(pwd)
#
function findAppletSrcDir() {
	local dir="${1}"

	local result=""
	while [[ -z "${result}" && "${dir}" != "/" ]]; do
		if [[ -d "${dir}/src" ]]; then
			if [[ -f "${dir}/src/metadata.desktop" ]]; then
				result="$(realpath "${dir}/src")"
			fi
		fi

		if [[ -z "${result}" ]]; then
			dir="$(dirname "${dir}")"
		fi
	done

	echo "${result}"
}

# ----------------------------------------------------------

# Builds plasmoid target file name based on medata.desktop content
#
# File name format: ${name}-${version}.plasmoid
#
function buildPlasmoidFileName() {
	local -r pkg_version="$(getMetaTag "X-KDE-PluginInfo-Version")"
	local -r pkg_name="$(getMetaTag "X-KDE-PluginInfo-Name")"
	local -r pkg_base_name=$(echo "${pkg_name}" | awk '{cnt=split($0,a,"."); print a[cnt]}')
	echo "${pkg_base_name}-${pkg_version}.plasmoid"
}

# ----------------------------------------------------------

# Escapes given string so it won't be treated as regular expression
# when handed to sed or elsewhere
#
# Returns:
#	escaped string
function escape() {
	local -r str="${1:-}"
	echo $(echo "${str}" | sed -e 's/[]\/$*.^[]/\\&/g')
}

# ----------------------------------------------------------

if [[ -z "${ROOT_DIR}" ]]; then
	echo "*** ROOT_DIR must be declared and cannot be empty."
	exit 1
fi

declare -r PLASMOID_ROOT="$(findAppletSrcDir "$(pwd)")"
if [[ -z "${PLASMOID_ROOT}" ]]; then
	echo "*** Unable to locate applet source dir from $(pwd)"
	exit 1
fi

