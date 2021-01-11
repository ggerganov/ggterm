#!/bin/bash

cd `dirname $0`
PWD=`pwd`

echo "[+] Updating submodules"
git submodule update --init

echo "[+] Installing powerline-shell"

function require_pkg {
    if [ "`dpkg -l $1 | grep $1 | grep -v none`" == "" ] ; then
        echo "Please install '$1' first:"
        echo ""
        echo "        $ sudo apt-get install $1"

        exit 1
    fi
}

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    require_pkg vim
    require_pkg g++
    require_pkg git
    require_pkg cmake
    require_pkg python-setuptools
    require_pkg python3
    require_pkg python3-dev
    require_pkg python3-pip
fi

cd ./submodules/powerline-shell
sudo python setup.py install
cd ../../
#ln -f -s ${PWD}/submodules/powerline-shell/powerline-shell.py ~/.powerline-shell.py

echo "[+] Checking if ~/.vim exists"
if [ -e ~/.vim ] ; then
    echo "~/.vim already exists. Nothing to do"
else
    echo "[+] Creating ~/.vim symlink"
    ln -s ${PWD}/.vim ~/.vim
fi

echo "[+] Creating ~/.* symlinks"
ln -f -s ${PWD}/.vimrc ~/.vimrc
ln -f -s ${PWD}/.myenv ~/.myenv
ln -f -s ${PWD}/.gdbinit ~/.gdbinit

mkdir -p ~/.vim/bundle
ln -f -s ${PWD}/submodules/Vundle.vim ~/.vim/bundle/Vundle.vim

echo "[+] Installing Vim plugins"
vim +PluginInstall +qall

if [ ! -e "./.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core.so" ] ; then
    echo "[+] Compiling YCM with semantic support for C-family languages"

    cd ~/.vim/bundle/YouCompleteMe
    ./install.py --clang-completer
    cd ${PWD}
fi

echo "[+] Setting up Language Client"

if [ ! -e "./.vim/bundle/LanguageClient-neovim/bin/languageclient" ] ; then
    echo "[+] Running LanguageClient-neovim install.sh"

    cd ~/.vim/bundle/LanguageClient-neovim
    ./install.sh
    cd ${PWD}
fi

echo "[+] Language server 'clangd' installation instructions"
echo "    sudo apt-get install clangd-10"
echo "    sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-10 100"

echo "[+] Done"
