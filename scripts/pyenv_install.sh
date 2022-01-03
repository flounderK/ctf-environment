#!/bin/bash

curl https://pyenv.run | bash

GLOBAL_VERSION="3.8.10"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
echo "$PATH"
eval "$(pyenv virtualenv-init -)"
PYENV_VERSIONS_DIR="$PYENV_ROOT/versions"

if [[ -f /.dockerenv && -d /pyenv_versions_cache ]]; then
	echo "In docker container and pyenv versions cache found"
	mkdir -p "$PYENV_VERSIONS_DIR"
	for i in $(find /pyenv_versions_cache -maxdepth 1 -mindepth 1 -type d); do
		# ln -f -s "$PYENV_VERSIONS_DIR/$(basename $i)" "$i"
		if [ ! -d "$PYENV_VERSIONS_DIR/$(basename $i)" ]; then
			cp -r "$i" "$PYENV_VERSIONS_DIR/$(basename $i)"
		fi
	done
fi

RCFILE="$HOME/.bashrc"

BUILD_DEPS_URL=https://github.com/pyenv/pyenv/wiki#suggested-build-environment

echo "Fetching build deps"
UBUNTU_BUILD_DEPS_STR=$(curl "$BUILD_DEPS_URL" | grep --color=never -Poz '(?<=copy-content=")sudo apt[^"]*' | tr -d '\n' | tr -d '\\' | sed 's/ install / install -y /g')

echo "\nRunning '$UBUNTU_BUILD_DEPS_STR'\n"
eval "$UBUNTU_BUILD_DEPS_STR"

RETRY_COUNT=0
until pyenv install -s "$GLOBAL_VERSION" || (( RETRY_COUNT++ > 5 ))
do echo "Pyenv install failed"
	sleep 5
	echo "Trying again"
done
pyenv global "$GLOBAL_VERSION"

if [[ -f /.dockerenv && -d /pyenv_versions_cache ]]; then
	for i in $(find "$PYENV_VERSIONS_DIR" -maxdepth 1 -mindepth 1 -type d); do
		if [ ! -d "/pyenv_versions_cache/$(basename $i)" ]; then
			cp -r "$i" /pyenv_versions_cache
		fi
	done
fi


# the sed invocation inserts the lines at the start of the file
# after any initial comment lines
sed -Ei -e '/^([^#]|$)/ {a \
export PYENV_ROOT="$HOME/.pyenv"
a \
export PATH="$PYENV_ROOT/bin:$PATH"
a \
' -e ':a' -e '$!{n;ba};}' ~/.profile
echo 'eval "$(pyenv init --path)"' >> ~/.profile

echo 'eval "$(pyenv init -)"' >> ~/.bashrc

source "$HOME/.profile" && source "$HOME/.bashrc"

echo 'Updating pip'
pip install -U pip
pip install -U setuptools

echo 'pyenv will be fully initialized on next login. Until then, you can run these lines in any terminal that you create'
echo 'source ~/.profile && source ~/.bashrc'

# echo 'export PYENV_ROOT="$HOME/.pyenv"'
# echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
# echo 'eval "$(pyenv init --path)"'
# echo 'eval "$(pyenv init -)"'
