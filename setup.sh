#!/usr/bin/env bash
# This script installs dotfiles

# include helpers
source ./lib/message.sh
source ./lib/requirements.sh

clear
echo ''
echo '        _       _    __ _ _           '
echo '     __| | ___ | |_ / _(_) | ___  ___ '
echo '    / _` |/ _ \| __| |_| | |/ _ \/ __|'
echo '   | (_| | (_) | |_|  _| | |  __/\__ \'
echo '    \__,_|\___/ \__|_| |_|_|\___||___/'
echo '                                      '

message "Checking sudo ..."
sudo -v

message "Checking requirements ..."
require_stow
message "  ... stow"
require_misc
message "  ... git"
require_git
message "  ... gitflow"
require_gitflow
message "  ... node/npm"
require_node

message "Updating dotfiles ..."
git pull origin master

# ###########################################################
# Git Config
# ###########################################################
message "Configuring .gitconfig ..."
if [ ! -f ./packages/git/.gitconfig -o ./packages/git/.gitconfig.dist -nt ./packages/git/.gitconfig ]
then
  echo "What is..."
  read -r -p "  ... your first name? " firstname
  read -r -p "  ... your family name? " lastname
  read -r -p "  ... your email? " email
  read -r -p "  ... your github username? " githubuser

  if [[ -z $firstname ]]
  then
    firstname=$(getent passwd $(whoami) | cut -d ':' -f 5 | cut -d ',' -f 1 | cut -d ' ' -f 2)
  fi
  if [[ -z $lastname ]]
  then
    lastname=$(getent passwd $(whoami) | cut -d ':' -f 5 | cut -d ',' -f 1 | cut -d ' ' -f 2)
  fi
  fullname="${firstname^} ${lastname^^}"

  cp ./packages/git/.gitconfig.dist ./packages/git/.gitconfig
  sed -i "s/__GITUSER__/$fullname/" ./packages/git/.gitconfig
  sed -i "s/__GITEMAIL__/$email/" ./packages/git/.gitconfig
  sed -i "s/__GITHUBUSER__/$githubuser/" ./packages/git/.gitconfig
fi

# ###########################################################
# stow packages
# ###########################################################
for dir in $(ls packages)
do
  package=$(basename $dir)
  message "Configuring package $package ..."
  stow --verbose --ignore=.dist --dir packages --target "$HOME" "$package"
done
message "All done"
