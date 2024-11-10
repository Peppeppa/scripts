#!/bin/bash

#Dotfiles Git bare repo init script

# git init in sidefolder .cfg/ 
git init --bare $HOME/.cfg

# set a temporary alias to use "config" instead of "git"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# set flag to hide files we are not explicitly tracking yet
config config --local status.showUntrackedFiles no

#save the config alias in .bashrc
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc

# nach folgendem tutorial:
# https://www.atlassian.com/git/tutorials/dotfiles
