#!/bin/bash

mkdir -p "$HOME/.local/bin"

ln -f -s /opt/ghidra/ghidraRun "$HOME/.local/bin/ghidra"
ln -f -s /opt/upx/upx "$HOME/.local/bin/upx"
ln -f -s /opt/cutter/*.AppImage "$HOME/.local/bin/cutter"
ln -f -s /opt/codeql/codeql "$HOME/.local/bin/codeql"

