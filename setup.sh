#!/bin/bash

top="$(dirname "$(readlink -f "$0")")"

#set -x
set -e

# Colors
ESC_SEQ="\e["
COL_RESET=$ESC_SEQ"39m"
COL_RED=$ESC_SEQ"31m"
COL_GREEN=$ESC_SEQ"32m"
COL_YELLOW=$ESC_SEQ"33m"
COL_BLUE=$ESC_SEQ"34m"
COL_MAGENTA=$ESC_SEQ"35m"
COL_CYAN=$ESC_SEQ"36m"

message() {
  /bin/echo -e "\n$COL_GREEN*** $1$COL_RESET"
}

ok() {
  /bin/echo -e "$COL_GREEN[ok]$COL_RESET "$1
}

running() {
  /bin/echo -e "$COL_YELLOW ⇒ $COL_RESET"$1": "
}

action() {
  /bin/echo -e "\n$COL_YELLOW[action]:$COL_RESET\n ⇒ $1..."
}

warn() {
  /bin/echo -e "$COL_YELLOW[warning]$COL_RESET "$1
}

error() {
  /bin/echo -e "$COL_RED[error]$COL_RESET "$1
}

clear
echo ''
echo '        _       _    __ _ _           '
echo '     __| | ___ | |_ / _(_) | ___  ___ '
echo '    / _` |/ _ \| __| |_| | |/ _ \/ __|'
echo '   | (_| | (_) | |_|  _| | |  __/\__ \'
echo '    \__,_|\___/ \__|_| |_|_|\___||___/'
echo '                                      '

message "Checking ansible requirement"
command -v ansible >/dev/null 2>&1 || {
  action "ansible not found, installing via apt"
  running "add-apt-repository ppa:ansible/ansible"
  sudo add-apt-repository --yes --update ppa:ansible/ansible &>/dev/null && echo "OK"
  running "apt-get install ansible"
  sudo DEBIAN_FRONEND=noninterractive apt-get install -qq --yes ansible </dev/null >/dev/null && echo "OK"
}
running "ansible --version"
ansible --version
ok

command -v git >/dev/null 2>&1 && {
  message "Updating dotfiles"
  git pull origin master
}

message "Need some configuration"
if [ -f $HOME/.gitconfig ]
then
  firstname=$(grep 'name.*=.*' $HOME/.gitconfig | sed -e 's/.*name\s*=\s//' | cut -d ' ' -f 1)
  lastname=$(grep 'name.*=.*' $HOME/.gitconfig | sed -e 's/.*name\s*=\s//' | cut -d ' ' -f 2)
  email=$(grep 'email.*=.*' $HOME/.gitconfig | sed -e 's/.*email\s*=\s//')
  githubuser=$(grep 'user.*=.*' $HOME/.gitconfig | sed -e 's/.*user\s*=\s//')
else
  firstname=$(getent passwd $(whoami) | cut -d ':' -f 5 | cut -d ',' -f 1 | cut -d ' ' -f 2)
  lastname=$(getent passwd $(whoami) | cut -d ':' -f 5 | cut -d ',' -f 1 | cut -d ' ' -f 2)
  email=
  githubuser=
fi

echo "What is..."
read -r -p "  ... your first name? " -i "$firstname" -e firstname
read -r -p "  ... your family name? " -i "$lastname" -e lastname
read -r -p "  ... your email? " -i "$email" -e email
read -r -p "  ... your github username? " -i "$githubuser" -e githubuser

message "Starting playbook"
export ANSIBLE_CONFIG="${top}/ansible.cfg"
ansible-playbook \
  -l localhost \
  --become --ask-become-pass \
  --extra-vars="firstname=$firstname" \
  --extra-vars="lastname=$lastname" \
  --extra-vars="email=$email" \
  --extra-vars="githubuser=$githubuser" \
  --extra-vars="username=$USER" \
  --extra-vars="groupname=$(id --name --group "$USER")" \
  --extra-vars="homedir=$HOME" \
  --extra-vars="dotdir=$top" \
  dotfiles.yml

message "Configure Gnome Terminal"
profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
profile=${profile:1:-1}
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" default-size-columns 120
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" default-size-rows 60
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color "rgb(211,211,211)"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" palette "['rgb(46,52,54)', 'rgb(204,0,0)', 'rgb(78,154,6)', 'rgb(196,160,0)', 'rgb(52,101,164)', 'rgb(117,80,123)', 'rgb(6,152,154)', 'rgb(211,215,207)', 'rgb(85,87,83)', 'rgb(239,41,41)', 'rgb(138,226,52)', 'rgb(252,233,79)', 'rgb(114,159,207)', 'rgb(173,127,168)', 'rgb(52,226,226)', 'rgb(238,238,236)']"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" custom-command "zsh"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" cursor-background-color "rgb(78,154,6)"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-system-font "false"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" cursor-colors-set "true"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" highlight-colors-set "false"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-theme-colors "false"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-custom-command "true"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" font "Monospace 9"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" cursor-foreground-color "rgb(0,0,0)"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" scrollback-unlimited "true"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-transparent-background "true"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-theme-transparency "false"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color "rgb(64,24,76)"
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-transparency-percent 10
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" audible-bell "false"

