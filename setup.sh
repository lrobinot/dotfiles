#!/usr/bin/env bash
# This script installs dotfiles

top=$(git rev-parse --show-toplevel)

# include helpers
source ${top}/lib/message.sh
source ${top}/lib/requirements.sh

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
if [ ! -f ${top}/packages/git/.gitconfig -o ${top}/packages/git/.gitconfig.dist -nt ${top}/packages/git/.gitconfig ]
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

  cp ${top}/packages/git/.gitconfig.dist ${top}/packages/git/.gitconfig
  sed -i "s/__GITUSER__/$fullname/" ${top}/packages/git/.gitconfig
  sed -i "s/__GITEMAIL__/$email/" ${top}/packages/git/.gitconfig
  sed -i "s/__GITHUBUSER__/$githubuser/" ${top}/packages/git/.gitconfig
fi

# ###########################################################
# Install bash.d scripts
# ###########################################################
message "Configuring bash.d ..."
cp ${top}/bash.d/git-bash-prompt.sh.dist ${top}/bash.d/git-bash-prompt.sh
sed -i "s@__TOP__@${top}@" ${top}/bash.d/git-bash-prompt.sh

grep -qF '# BEGIN -- DOTFILES' $HOME/.bashrc
if [ $? -ne 0 ]
then
  cat<<END >>$HOME/.bashrc
# BEGIN -- DOTFILES
if [ -d ${top}/bash.d ]
then
  for i in ${top}/bash.d/*.sh
  do
    if [ -r \$i ]
    then
      . \$i
    fi
  done
  unset i
fi
# END -- DOTFILES
END
fi

# ###########################################################
# Import dconf files
# ###########################################################
for file in $(ls dconf)
do
  target=$(sed "s@_@/@g" <<<${file%.txt})
  message "Importing configuration $target ..."
  dconf load $target < ${top}/dconf/$file
done

# ###########################################################
# stow packages
# ###########################################################
for dir in $(ls ${top}/packages)
do
  package=$(basename $dir)
  message "Configuring package $package ..."
  stow --verbose --ignore=.dist --dir packages --target "$HOME" "$package"
done
message "All done"
