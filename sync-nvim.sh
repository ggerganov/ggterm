#!/bin/bash

if [ ! -d ~/.config/nvim ] ; then
    echo "~/.config/nvim is missing"
    exit 1
fi

cd `dirname $0`
PWD=`pwd`

cat ~/.vimrc | sed -e "s/\/\.vim/\/.config\/nvim/g" > ~/.config/nvim/init.vim

mkdir -p ~/.config/nvim/lua
ln -sfn ${PWD}/init.lua ~/.config/nvim/lua/init.lua
