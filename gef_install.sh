#!/bin/sh

if [ -z $(command -v git) ];then
	echo "Please install git"
	exit 1
fi

if [ -z $(command -v gdb) ];then
	echo "Please install gdb"
	exit 1
fi


GEF_INSTALL_LOCATION="$HOME/.local/share/gef"
GEF_SOURCE_LINE="source ~/.local/share/gef/gef.py"

if [ ! -d "$GEF_INSTALL_LOCATION" ];then
	git clone https://github.com/hugsy/gef.git "$GEF_INSTALL_LOCATION"
fi

ORIGINAL_DIR=$(pwd)

PYTHON_VERSION=$(gdb --nx -q -ex 'python from __future__ import print_function;import sys;print(sys.version)' -ex 'q' | head -n1 | cut -c1)

PYTHON_BIN=$(which "python$PYTHON_VERSION")

$PYTHON_BIN -mpip --version 1>/dev/null

if [ "$?" -ne 0 ];then
	echo "It looks like you don't have pip installed for $PYTHON_BIN, the python version gdb is using"
	echo "Please install pip via your package manager or $PYTHON_BIN -mensurepip"
	exit 1
fi


echo "INSTALLING GEF"
cd "$GEF_INSTALL_LOCATION"
$PYTHON_BIN -mpip install -r requirements.txt

cd "$ORIGINAL_DIR"

GEF_SOURCELINE_NEEDED=1

if [ -f "$HOME/.gdbinit" ];then
	GEF_SOURCED_MATCH=$(grep "$GEF_SOURCE_LINE" "$HOME/.gdbinit")
	if [ ! -z "$GEF_SOURCED_MATCH" ];then
		GEF_SOURCELINE_NEEDED=0
	fi
fi

if [ "$GEF_SOURCELINE_NEEDED" -ne 0 ];then
	echo "$GEF_SOURCE_LINE" >> "$HOME/.gdbinit"
fi

echo "GEF installed"
