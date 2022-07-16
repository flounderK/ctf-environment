#!/bin/bash


SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

print_usage () {
	echo "Usage: ./install.sh [-p|--pyenv-install]"
	echo "       -p|--pyenv-install: install python through pyenv"

}

PYENV_INSTALL=0
DRY_RUN=0

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
	case $1 in
		-p|--pyenv-install)
			PYENV_INSTALL=1
			shift
			;;
		-d|--dry-run)
			DRY_RUN=1
			shift
			;;
		-h|--help)
			print_usage
			exit 0
			;;
		-*|--*)
			echo "unknown option $1"
			print_usage
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1")
			shift
			;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}"

if [ $DRY_RUN -eq 1 ]; then
	echo "PYENV_INSTALL $PYENV_INSTALL"
	echo "DRY_RUN $DRY_RUN"
	exit 0
fi

ORIGINAL_DIR=$(pwd)
cd "$DIR"
git submodule init
git submodule update --remote
cd "$ORIGINAL_DIR"

mkdir -p "$HOME/.local/bin"

# needed by other steps or just useful packages
$DIR/scripts/install_core_packages.sh $DIR/config/packagelist

if [ $PYENV_INSTALL -eq 1 ]; then
	# install a user controlled python enviornment
	$DIR/scripts/pyenv_install.sh
	. "$HOME/.profile"
	. "$HOME/.bashrc"

	pip install -r "$DIR/config/python_packages.txt"
else
	pip install --user -U pip
	pip install --user -U setuptools
	. "$HOME/.profile"
	. "$HOME/.bashrc"
	pip install --user -r "$DIR/config/python_packages.txt"
fi

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
