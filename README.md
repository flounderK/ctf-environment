__TOC__

# ctf-environment
Automatically set up an environment for playing ctf. Target version is currently Ubuntu 18.04 / 20.04.

**NOTE: Kali Linux is NOT recommended for this environment. It is also NOT recommended for playing CTF, as Kali is not intended for long term installation and will likely break on reboot**

## Installation
```bash
./install.sh
```
Then **log out and back in again** for all changes to take effect. 


If you can't logout first, you will have to run the following command in all terminals to use the pyenv installation of python:
```bash
source ~/.profile && source ~/.bashrc
```

### Install specific components

## What is installed?

### Pyenv
[pyenv](https://github.com/pyenv/pyenv) removes the limitations of using ubuntu's default python installation. The version of `pip` available through `apt` is out of date, and typically restricts the versions of some packages that you can install. By using pyenv, the global version of python for the system won't interfere with the version of python for your user, and vis versa. So upgrading packages through pip won't break any part of your system. As an added bonus, `pip3` no longer requires `sudo`.

### Ghidra
[ghidra](https://github.com/NationalSecurityAgency/ghidra) is an excellent tool for reverse engineering binary executables.

### Gef
[gef](https://github.com/hugsy/gef) is an extension for gdb that makes debugging binary executables much less painful.

### Pwntools
[pwntools](https://github.com/Gallopsled/pwntools) is a python package that helps with a lot of the more annoying aspects of writing ctf solutions (like communicating with a server in a python script, or converting c values to bytes). This makes pwn problems almost reasonable to solve.

### Cutter
[cutter](https://github.com/rizinorg/cutter) is a gui frontend for [radare2](https://github.com/radareorg/radare2), another tool for reverse engineering binaries.  

### Much more
A lot of basic utilities that make ctf much easier to approach. Also a few edits to your `PATH` that make tools accessible from the command line.

## Optional Additional stuff

### clone useful repos
```bash
./scripts/clone_git_repos.sh
```

## Development
For developers, you can test the install of scripts using the following commands:
```bash
docker build -t "ctf-env" .
docker run --rm -it ctf-env:latest bash
./install.sh
```

**note: source the following will be needed for anything using python:**
```bash
source ~/.profile && source ~/.bashrc
```

TODO: make a lot of this ansible based
