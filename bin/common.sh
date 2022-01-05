#!/bin/bash

# KDE Plasma Applets Developer Tools
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2020-2022 Marcin Orlowski
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
	local -r _tag="${1:-}"
	local -r _default="${2:-}"
	local -r _meta_file="${3:-${PLASMOID_ROOT}/metadata.desktop}"

	local _result="$(grep "^${_tag}=" < "${_meta_file}" | awk '{split($0,a,"="); print a[2]}')"
	if [[ -z "${_result}" ]]; then
		_result="${_default}"
	fi

	echo "${_result}"
}

# ----------------------------------------------------------

# Echos some data from metadata.desktop file as JS code.
# This is to work around limitation of QML not exporting
# metadata unless post v5.76 of KDE QML framework.
#
function dumpMeta() {
	local -r _pkg_version="$(getMetaTag "X-KDE-PluginInfo-Version")"
	local -r _author_name="$(getMetaTag "X-KDE-PluginInfo-Author")"
	local -r _author_url="$(getMetaTag "X-KDE-PluginInfo-Author-Url")"
	local -r _project_name="$(getMetaTag "Name")"
	local -r _project_url="$(getMetaTag "X-KDE-PluginInfo-Website")"
	local -r _update_checker_url="$(getMetaTag "X-KDE-PluginInfo-UpdateChecker-Url")"
	local -r _first_release_year="$(getMetaTag "X-KDE-PluginInfo-FirstReleaseYear" 1980)"

	echo -e \
"// This file is auto-generated. DO NOT EDIT BY HAND\n"\
"// Generated: $(date --iso-8601=seconds)\n"\
"\n"\
"// https://doc.qt.io/qt-5/qtqml-javascript-resources.html\n"\
".pragma library\n"\
"\n"\
"const version=\"${_pkg_version}\"\n"\
"const title=\"${_project_name}\"\n"\
"const url=\"${_project_url}\"\n"\
"const authorName=\"${_author_name}\"\n"\
"const authorUrl=\"${_author_url}\"\n"\
"const updateCheckerUrl=\"${_update_checker_url}\"\n"\
"const firstReleaseYear=${_first_release_year}\n"
}

# ----------------------------------------------------------

# Looks for a plasmoid valid root folder. Starts from ${_dir}
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
	local _dir="${1}"

	local _result=""
	while [[ -z "${_result}" && "${_dir}" != "/" ]]; do
		if [[ -d "${_dir}/src" ]]; then
			if [[ -f "${_dir}/src/metadata.desktop" ]]; then
				_result="$(realpath "${_dir}/src")"
			fi
		fi

		if [[ -z "${_result}" ]]; then
			_dir="$(dirname "${_dir}")"
		fi
	done

	echo "${_result}"
}

# ----------------------------------------------------------

# Builds plasmoid target file name based on medata.desktop content
#
# File name format: ${_name}-${_version}.plasmoid
#
function buildPlasmoidFileName() {
	local -r _pkg_version="$(getMetaTag "X-KDE-PluginInfo-Version")"
	local -r _pkg_name="$(getMetaTag "X-KDE-PluginInfo-Name")"
	local -r _pkg_base_name=$(echo "${_pkg_name}" | awk '{cnt=split($0,a,"."); print a[cnt]}')
	echo "${_pkg_base_name}-${_pkg_version}.plasmoid"
}

# ----------------------------------------------------------

# Escapes given string so it won't be treated as regular expression
# when handed to sed or elsewhere
#
# Returns:
#	escaped string
function escape() {
	local -r _str="${1:-}"
	echo $(echo "${_str}" | sed -e 's/[]\/$*.^[]/\\&/g')
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

# ----------------------------------------------------------

source "${ROOT_DIR}/bin/colors.sh"

# ----------------------------------------------------------

##############################################################################
#
# Shows given error message and then terminates script execution with exit 
# code 1.
#
# Arguments:
#	      msg: Optional message string to show. Default "Aborted"
#
function abort {
	echo -e "${ERROR}*** ${1:-Aborted.}"
	exit 1
}

