#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"


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

if [ -d "$GEF_INSTALL_LOCATION" ]; then
	echo "GEF already installed, skipping"
	exit 0
fi

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
else
	cp "$DIR/../gdbinit" "$HOME/.gdbinit"
	GEF_SOURCELINE_NEEDED=0
fi

if [ "$GEF_SOURCELINE_NEEDED" -ne 0 ];then
	echo "$GEF_SOURCE_LINE" >> "$HOME/.gdbinit"
fi

echo "GEF installed"

# if [ -f "$HOME/.gdbinit" ]; then
	# mv "$HOME/.gdbinit" "$HOME/.gdbinit.bak"
	# echo "Moved existing gdbinit to $HOME/.gdbinit.bak"
# fi

# cp "$DIR/../gdbinit" "$HOME/.gdbinit"

