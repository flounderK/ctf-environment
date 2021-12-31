#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"


ORIGINAL_DIR=$(pwd)

mkdir -p ~/cloned
cd ~/cloned

for i in $(cat "$DIR/../config/gitrepos"); do
	DESTNAME=$(echo "$i" | grep --color=never -Po '[^/]+$')
	DESTNAME="${DESTNAME%.git}"
	if [ ! -d "$DESTNAME" ]; then
		git clone "$i"
	else
		echo "skipping $i"
	fi
done

cd "$ORIGINAL_DIR"
