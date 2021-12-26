#!/bin/bash

INSTALL_DIR="/opt"
SORTED_DIRS=$(find "$INSTALL_DIR" -maxdepth 1 -mindepth 1 -type d -exec ls -1dt "{}" \;)

link_last_modified() {
	# 1 is match
	# 2 is linkname
	TARGET=$(echo "$SORTED_DIRS" | grep --color=never -i "$1" | head -n1)
	LINK="$INSTALL_DIR/$2"
	echo "target $TARGET"
	echo "link $LINK"
	sudo ln -f -s "$TARGET" "$LINK"
}

link_last_modified "upx" "upx"
link_last_modified "ghidra" "ghidra"
link_last_modified "cutter" "cutter"
