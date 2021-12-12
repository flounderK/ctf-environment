#!/bin/sh

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 'owner/repo'"
	exit 1
fi
URL=$(curl "https://api.github.com/repos/$1/releases/latest" | grep --color=never -Po '(?<=browser_download_url": ")[^"]+')
wget "$URL" 
echo $(basename "$URL")
