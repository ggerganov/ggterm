#!/bin/bash

cd `dirname $0`
PWD=`pwd`

echo "[+] Updating submodules"
git submodule update --init

function require_pkg {
    if [ ! command -v $1 &> /dev/null ] && [ "`dpkg -l $1 | grep $1 | grep -v none`" == "" ] ; then
        echo "Please install '$1' first:"
        echo ""
        echo "    Linux: sudo apt-get install $1"
        echo "    Mac    brew install $1"
        echo ""

        exit 1
    fi
}

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    require_pkg vim
    require_pkg vim-gtk3
    require_pkg g++
    require_pkg git
    require_pkg cmake
    require_pkg python-setuptools
    require_pkg python3
    require_pkg python3-dev
    require_pkg python3-pip
    require_pkg starship
fi

echo "[+] Checking if ~/.config/kitty exists"
if [ -e ~/.config/kitty ] ; then
    echo "~/.config/kitty already exists. Nothing to do"
else
    echo "[+] Creating ~/.config/kitty symlink"
    ln -s ${PWD}/kitty ~/.config/kitty
fi

# if $OSTYPE contains the word "darwin"
if [[ "$OSTYPE" == "darwin"* ]]; then
    ln -sf ${PWD}/kitty/kitty-macos.conf ${PWD}/kitty/local.conf
else
    ln -sf ${PWD}/kitty/kitty-linux.conf ${PWD}/kitty/local.conf
fi

echo "[+] Creating ~/.* symlinks"
ln -f -s ${PWD}/.vimrc ~/.vimrc
ln -f -s ${PWD}/.gvimrc ~/.gvimrc
ln -f -s ${PWD}/.myenv ~/.myenv
ln -f -s ${PWD}/.gdbinit ~/.gdbinit
ln -f -s ${PWD}/.gitconfig ~/.gitconfig
ln -f -s ${PWD}/starship.toml ~/.config/starship.toml

mkdir ~/.vim/swapfiles
mkdir ~/.vim/undodir

git update-index --assume-unchanged .gitconfig

echo "[+] Done"
