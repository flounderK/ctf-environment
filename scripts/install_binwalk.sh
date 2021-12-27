#!/bin/bash

ORIGINAL_DIR=$(pwd)
mkdir -p ~/.local/share/
mkdir -p ~/.local/bin

git clone https://github.com/ReFirmLabs/binwalk.git ~/.local/share/binwalk

cd ~/.local/share/binwalk
./deps.sh
python3 setup.py install --install-scripts ~/.local/bin

cd "$ORIGINAL_DIR"
