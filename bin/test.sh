#!/bin/bash

# KDE Plasma Applets Developer Tools
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2020-2022 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/plasmoid-tools
#

set -euo pipefail

# shellcheck disable=SC2155
declare -r ROOT_DIR="$(realpath "$(dirname "$(realpath "${0}")")/..")"
source "${ROOT_DIR}/bin/common.sh"

function testPlasmoid() {
	# https://stackoverflow.com/questions/41409273/file-line-and-function-for-qml-files
	# https://doc.qt.io/qt-5/qtglobal.html#qSetMessagePattern
	#export QT_MESSAGE_PATTERN="[%{type}] %{appname} (%{file}:%{line}) - %{message}"
	#export QT_MESSAGE_PATTERN="%{time} %{file}:%{line}: %{message}"
	export QT_MESSAGE_PATTERN="%{time} L%{line} %{message}"

	# https://doc.qt.io/qt-5.15/qmldiskcache.html
	export QML_DISABLE_DISK_CACHE=1

	if [[ $# -ge 1 ]]; then
		echo "Running FullRepresentation"
		plasmoidviewer --applet "${PLASMOID_ROOT}"
	else
		echo "Running CompactRepresentation"
		plasmoidviewer \
    		--formfactor vertical \
		    --location topedge \
			--applet "${PLASMOID_ROOT}" \
		    --size 140X150 

			# --applet "${ROOT_DIR}/src"
	    	# --size "196X96"
	fi
}

testPlasmoid $@
