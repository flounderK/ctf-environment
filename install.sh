#!/bin/bash


SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

ORIGINAL_DIR=$(pwd)
cd "$DIR"
git submodule init
git submodule update
cd "$ORIGINAL_DIR"

mkdir -p "$HOME/.local/bin"

eval "$DIR/scripts/install_core_packages.sh"
eval "$DIR/scripts/pyenv_install.sh"
source "$HOME/.profile"
source "$HOME/.bashrc"
pip install -r "$DIR/config/python_packages.txt"
eval "$DIR/scripts/gef_install.sh"
eval "$DIR/scripts/GithubReleaseDownloader/github_release_downloader.py -d releases -j $DIR/config/github_release_downloads.json"

eval "sudo -s $DIR/scripts/GithubReleaseDownloader/github_release_installs.sh releases"

eval "$DIR/scripts/install_priv_symlinks.sh"

eval "$DIR/scripts/install_user_symlinks.sh"
# eval "$DIR/scripts/snap_installs.sh"

