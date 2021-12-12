#!/bin/sh
wget $(curl https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest | grep --color=never -Po '(?<=browser_download_url": ")[^"]+')
