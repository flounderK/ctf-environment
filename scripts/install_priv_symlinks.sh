#!/bin/bash

INSTALL_DIR="/opt"
# find directories in the install dir and sort them by last modified
# date
SORTED_DIRS=$(find "$INSTALL_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%T+ %p\n" | sort -r | cut -d ' ' -f2)

link_last_modified() {
	# 1 is match
	# 2 is linkname
	TARGET=$(echo "$SORTED_DIRS" | grep --color=never -i "$1" | head -n1)
	LINK="$INSTALL_DIR/$2"
	echo "target $TARGET"
	echo "link $LINK"
	if [ -L "$LINK" ]; then
		rm -f "$LINK"
	fi
	sudo ln -f -s "$TARGET" "$LINK"
}

link_last_modified "upx" "upx"
link_last_modified "ghidra" "ghidra"
link_last_modified "cutter" "cutter"
