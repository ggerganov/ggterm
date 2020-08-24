#!/bin/bash

defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

echo -n "KeyRepeat: "
defaults read NSGlobalDomain KeyRepeat -int 1

echo -n "InitialKeyRepeat: "
defaults read NSGlobalDomain InitialKeyRepeat -int 10

echo "Now relog for settings to take effect"
