#!/usr/bin/env bash
git init --bare $HOME/dotfiles
alias dotconfig="/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"
source .bashrc
dotconfig config --local status.showUntrackedFiles no
rm .bashrc
dotconfig pull https://github.com/gaeriel79/dotfiles