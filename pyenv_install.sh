#!/bin/bash

curl https://pyenv.run | bash

GLOBAL_VERSION="3.8.0"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv virtualenv-init -)"

RCFILE="$HOME/.bashrc"

BUILD_DEPS_URL=https://github.com/pyenv/pyenv/wiki#suggested-build-environment

echo "Fetching build deps"
UBUNTU_BUILD_DEPS_STR=$(curl "$BUILD_DEPS_URL" | grep --color=never -Poz '(?<=copy-content=")sudo apt[^"]*' | tr -d '\n' | tr -d '\\' | sed 's/ install / install -y /g')

echo "\nRunning '$UBUNTU_BUILD_DEPS_STR'\n"
eval "$UBUNTU_BUILD_DEPS_STR"

pyenv install "$GLOBAL_VERSION"
pyenv global "$GLOBAL_VERSION"


# the sed invocation inserts the lines at the start of the file
# after any initial comment lines
sed -Ei -e '/^([^#]|$)/ {a \
export PYENV_ROOT="$HOME/.pyenv"
a \
export PATH="$PYENV_ROOT/bin:$PATH"
a \
' -e ':a' -e '$!{n;ba};}' ~/.profile
echo 'eval "$(pyenv init --path)"' >>~/.profile

echo 'eval "$(pyenv init -)"' >> ~/.bashrc

source "$HOME/.profile"

echo 'Updating pip'
pip install -U pip

echo 'pyenv will be fully initialized on next login. Until then, you can run these lines in any terminal that you create'
echo 'source ~/.profile && source ~/.bashrc'

# echo 'export PYENV_ROOT="$HOME/.pyenv"'
# echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
# echo 'eval "$(pyenv init --path)"'
# echo 'eval "$(pyenv init -)"'
