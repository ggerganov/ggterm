#!/bin/bash

if [ ! -d ~/.config/nvim ] ; then
    echo "~/.config/nvim is missing"
    exit 1
fi

cat ~/.vimrc | sed -e "s/\/\.vim/\/.config\/nvim/g" > ~/.config/nvim/init.vim
