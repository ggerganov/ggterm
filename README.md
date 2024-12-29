# ggterm

My terminal configuration for C++ development with Vim/Neovim.

> [!WARNING] 
> Using this repo can mess up your existing environment!
> 
> It is highly recommended to first try it out in a fresh VM!

<img width="2560" alt="image" src="https://github.com/user-attachments/assets/f798a0f5-ac0a-40cd-b32d-272104745b88" />

## Quick start

The repo is meant to be used on Mac OS but could also work on Linux with some adaptations.

```bash
brew install vim neovim git cmake starship pyenv pyenv-virtualenv

pyenv install 3.11.4
pyenv virtualenv 3.11.4 py3nvim
pyenv activate py3nvim
pip install neovim

git clone https://github.com/ggerganov/ggterm --recursive
cd ggterm

./install.sh

# optionally add "source ~/.myenv" at the end of your ~/.bashrc
```

## Usage

My Vim usage is tab-oriented. Check the [.vimrc](.vimrc) file for all available shortcuts. Here is a partial list for convenience:

| Action | Shortcut |
| ------ | ------ |
| tn | open new tab |
| tc | clone current tab |
| t[0-9] | switch to tab [0-9] |
| tm[0-9] | move tab to position [0-9] |
| ;d | go to definition |
| ;r | list all references |
| \gl | all commits |
| \ga | commits for current file |
| \gdc | go to declaration |
| \rs | remove all trailing spaces |
| \lf | clang-format |
| \gH | open line in Github |
| \gB | blame line in Github |
| Ctrl + f | fuzzy search file |
| Ctrl + p | fuzzy search text |
| Ctrl + o | switch between source and header file |
| Ctrl + n | toggle NERD tree |
| Ctrl + l | open NERD tree in current folder |
| Ctrl + k | fuzzy search current text under cursor |
| F5 | Start debugging |
| F5 | Continue until break |
| F10 | Step over |
| F11 | Step into |
| F12 | Complete the current funcion |
| F9 | Toggle breakpoint |
| F3 | Stop debugging |
| F4 | Start again with same options	|
| F6 | Interrupt the debuger |
| F7 | Add watch expression from visual selection |
| \F8 | Run to cursor |
