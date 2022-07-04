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
git submodule update --remote
cd "$ORIGINAL_DIR"

mkdir -p "$HOME/.local/bin"

# needed by other steps or just useful packages
$DIR/scripts/install_core_packages.sh $DIR/config/packagelist

# install a user controlled python enviornment
$DIR/scripts/pyenv_install.sh
. "$HOME/.profile"
. "$HOME/.bashrc"

pip install -r "$DIR/config/python_packages.txt"

# full binwalk install
$DIR/scripts/install_binwalk.sh

# gdb enviornment
$DIR/scripts/gef_install.sh

# install packages that aren't in apt to /opt
$DIR/scripts/GithubReleaseDownloader/github_release_downloader.py -d releases -j $DIR/config/github_release_downloads.json

sudo -s $DIR/scripts/GithubReleaseDownloader/github_release_installs.sh releases
# Add symlinks for the new packages in /opt
$DIR/scripts/install_priv_symlinks.sh
$DIR/scripts/install_user_symlinks.sh

# install things that are now only available through snap
# this step is skipped in docker containers
command -v snap >/dev/null && $DIR/scripts/snap_installs.sh

$DIR/scripts/install_gem_packages.sh $DIR/config/geminstalls


echo "DONE!!"
echo ""
echo "You need to log out and then back in for all changes to "
echo "take effect. Until then, you can run to make your current shell work with pyenv's python:"
echo ". ~/.profile && . ~/.bashrc"
echo ""
