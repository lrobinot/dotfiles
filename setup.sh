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

cd "$top"

clear
echo ''
echo '     _       _    __ _ _                       '
echo '  __| | ___ | |_ / _(_) | ___  ___   _     _   '
echo ' / _` |/ _ \| __| |_| | |/ _ \/ __|_| |_ _| |_ '
echo '| (_| | (_) | |_|  _| | |  __/\__ \_   _|_   _|'
echo ' \__,_|\___/ \__|_| |_|_|\___||___/ |_|   |_|  '
echo '                                               '

wsl=$(cat /proc/version | grep -c -- -Microsoft || :)

message "Checking requirements"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq --yes dirmngr python-pip python-dev libffi-dev libssl-dev </dev/null >/dev/null && echo "OK"

message "Checking ansible requirement"
command -v ansible >/dev/null 2>&1 || {
  action "ansible not found, installing via apt"
  running "add-apt-repository ppa:ansible/ansible"
  sudo add-apt-repository --yes --update ppa:ansible/ansible &>/dev/null && echo "OK"
  running "apt-get install ansible"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq --yes ansible </dev/null >/dev/null && echo "OK"
}
running "ansible --version"
ansible --version
ok

command -v git >/dev/null 2>&1 && {
  message "Updating dotfiles"
  umask g-w,o-rwx
  git pull origin master
  # To update to new version of submodule
  #git submodule update --recursive --remote
  git submodule update --recursive
  ok
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

gnome_terminal_default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
gnome_terminal_default_profile=${gnome_terminal_default_profile:1:-1}
ok

message "Starting Ansible Playbook"
export ANSIBLE_CONFIG="${top}/ansible.cfg"
ansible-playbook \
  --inventory "${top}/inventory" \
  --limit localhost \
  --become --ask-become-pass \
  --extra-vars="firstname=$firstname" \
  --extra-vars="lastname=$lastname" \
  --extra-vars="email=$email" \
  --extra-vars="githubuser=$githubuser" \
  --extra-vars="username=$(id --user $USER)" \
  --extra-vars="groupname=$(id --group "$USER")" \
  --extra-vars="homedir=$HOME" \
  --extra-vars="dotdir=$(realpath --relative-to="$HOME" "$top")" \
  --extra-vars="wsl=$wsl" \
  --extra-vars="gnome_terminal_default_profile=$gnome_terminal_default_profile" \
  dotfiles.yml
ok
