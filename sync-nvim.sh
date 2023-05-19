#!/bin/bash

if [ ! -d ~/.config/nvim ] ; then
    echo "~/.config/nvim is missing"
    exit 1
fi

cat ~/.vimrc | sed -e "s/\/\.vim/\/.config\/nvim/g" > ~/.config/nvim/init.vim

mkdir -p ~/.config/nvim/lua
cp -v ./init.lua ~/.config/nvim/lua/init.lua
