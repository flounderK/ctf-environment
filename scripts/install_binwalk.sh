#!/bin/bash

ORIGINAL_DIR=$(pwd)
source ~/.profile && source ~/.bashrc
mkdir -p ~/.local/share/
mkdir -p ~/.local/bin

git clone https://github.com/ReFirmLabs/binwalk.git ~/.local/share/binwalk

cd ~/.local/share/binwalk
./deps.sh --yes

SITE_PACKAGES_DIR=$(python -c "import sys; print([i for i in sys.path if i.endswith('site-packages')][0])")
IS_PYENV=$(python -c "a='$SITE_PACKAGES_DIR'; print('1' if a.find('.pyenv') > -1 else '0')")

echo "$SITE_PACKAGES_DIR"

# this is to clean up after the deps.sh script, which by default
# tries to install everything as root regardless of location
if [ "$IS_PYENV" -ne 0 ]; then
	echo "pyenv install, running fixup"
	NAME=$(id -un)
	sudo chown -R $NAME:$NAME "$SITE_PACKAGES_DIR/../../.."
fi
python3 setup.py install --install-scripts ~/.local/bin

cd "$ORIGINAL_DIR"
