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
  /bin/echo -e "\n${COL_GREEN}*** ${1}${COL_RESET}"
}

ok() {
  /bin/echo -e "${COL_GREEN}[ok]${COL_RESET}"
}

running() {
  /bin/echo -e "${COL_YELLOW} ⇒ ${COL_RESET}${1}: "
}

action() {
  /bin/echo -e "\n${COL_YELLOW}[action]:${COL_RESET}\n ⇒ ${1}..."
}

warn() {
  /bin/echo -e "${COL_YELLOW}[warning]${COL_RESET} ${1}"
}

error() {
  /bin/echo -e "${COL_RED}[error]${COL_RESET} ${1}"
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

read -r -s -p "[sudo] password for $USER: " PASSWORD
echo ""
TEMPPASSWORD=$(mktemp --tmpdir="${top}" --quiet)
trap 'rm -f "${TEMPPASSWORD}"' EXIT
echo "$PASSWORD" >"${TEMPPASSWORD}"

sudo --stdin --validate >&/dev/null <"${TEMPPASSWORD}"

message "Checking requirements"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq --yes dirmngr libffi-dev libssl-dev python3-pip python3-dev python3-psutil </dev/null >/dev/null && echo "OK"

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

if [ -n "${1}" ]
then
  tags="--tags ${1}"
else
  tags=
fi

if [ -f "$HOME/.gitconfig" ]
then
  firstname=$(grep 'name.*=.*' "$HOME/.gitconfig" | sed -e 's/.*name\s*=\s//' | cut -d ' ' -f 1)
  lastname=$(grep 'name.*=.*' "$HOME/.gitconfig" | sed -e 's/.*name\s*=\s//' | cut -d ' ' -f 2)
  email=$(grep 'email.*=.*' "$HOME/.gitconfig" | sed -e 's/.*email\s*=\s//')
  githubuser=$(grep 'user.*=.*' "$HOME/.gitconfig" | sed -e 's/.*user\s*=\s//')
fi

if [ -z "${firstname}" ] || [ -z "${lastname}" ]
then
  firstname=$(getent passwd "$(whoami)" | cut -d ':' -f 5 | cut -d ',' -f 1 | cut -d ' ' -f 1)
  lastname=$(getent passwd "$(whoami)" | cut -d ':' -f 5 | cut -d ',' -f 1 | cut -d ' ' -f 2)

  message "Need some configuration"
  echo "What is ..."
  read -r -p "  ... your first name? " -i "$firstname" -e firstname
  read -r -p "  ... your family name? " -i "$lastname" -e lastname
  read -r -p "  ... your email? " -i "$email" -e email
  read -r -p "  ... your github username? " -i "$githubuser" -e githubuser
fi

wsl=$(grep -c -- -Microsoft /proc/version || :)
gnome_terminal_default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
gnome_terminal_default_profile=${gnome_terminal_default_profile:1:-1}
monitor=$(xrandr | grep '^DP-.*1920x1080+1920+0' | awk '{print $1}')

rm -f "${TEMPPASSWORD}"

message "Starting Ansible Playbook"
export ANSIBLE_CONFIG="${top}/ansible.cfg"
#  --become --ask-become-pass \
ansible-playbook \
  --inventory "${top}/inventory" \
  --limit localhost \
  --extra-vars="ansible_become_pass=$PASSWORD" \
  --extra-vars="firstname=$firstname" \
  --extra-vars="lastname=$lastname" \
  --extra-vars="email=$email" \
  --extra-vars="githubuser=$githubuser" \
  --extra-vars="username=${USER}" \
  --extra-vars="userid=$(id --user "$USER")" \
  --extra-vars="groupid=$(id --group "$USER")" \
  --extra-vars="homedir=$HOME" \
  --extra-vars="dotdir=$(realpath --relative-to="$HOME" "$top")" \
  --extra-vars="wsl=$wsl" \
  --extra-vars="gnome_terminal_default_profile=$gnome_terminal_default_profile" \
  --extra-vars="monitor=$monitor" \
  ${tags} \
  dotfiles.yml
ok
