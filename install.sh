#!/bin/bash

cd `dirname $0`
PWD=`pwd`

echo "[+] Updating submodules"
git submodule update --init

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
