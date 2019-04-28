#!/usr/bin/env bash

function require_misc() {
  PRE_INSTALL_PKGS=""

  if [ ! -e /usr/lib/apt/methods/https ]
  then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} apt-transport-https"
  fi

  if [ ! -x /usr/bin/lsb_release ]
  then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} lsb-release"
  fi

  if [ ! -x /usr/bin/curl ]
  then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} curl"
  fi

  if [ ! -x /usr/bin/gpg ]
  then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} gnupg"
  fi

  if [ "x$PRE_INSTALL_PKGS" != "x" ]
  then
    action "Miscellaneous packages required for setup: $PRE_INSTALL_PKGS"
    running "apt update"
    sudo apt-get -qq update && echo "OK"
    running "apt install ${PRE_INSTALL_PKGS}"
    sudo DEBIAN_FRONEND=noninterractive apt-get install -qq --yes ${PRE_INSTALL_PKGS} </dev/null >/dev/null && echo "OK"
  fi
}

function require_stow() {
  message "Checking stow requirement"
  running "stow --version"
  stow --version
  if [[ $? != 0 ]]
  then
    action "stow not found, installing via apt"
    running "apt -qq update"
    sudo apt-get -qq update && echo "OK"
    running "apt install stow"
    sudo DEBIAN_FRONEND=noninterractive apt-get install -qq --yes stow </dev/null >/dev/null && echo "OK"
  fi
  ok
}

function require_git() {
  message "Checking git requirement"
  running "git --version"
  git --version
  if [[ $? != 0 ]]
  then
    action "git not found, installing via apt"
    running "add-apt-repository ppa:git-core/ppa"
    sudo add-apt-repository --yes --no-update ppa:git-core/ppa &>/dev/null && echo "OK"
    running "apt -qq update"
    sudo apt-get -qq update && echo "OK"
    running "apt install git"
    sudo DEBIAN_FRONEND=noninterractive apt-get install -qq --yes git </dev/null >/dev/null && echo "OK"
  fi
  ok
}

function require_gitflow() {
  message "Checking gitflow requirement"
  running "git flow version"
  git flow version
  if [[ $? != 0 ]]
  then
    action "git-flow not found, installing via apt"
    running "apt -qq update"
    sudo apt-get -qq update && echo "OK"
    running "apt install git-flow"
    sudo DEBIAN_FRONEND=noninterractive apt-get install -qq --yes git-flow </dev/null >/dev/null && echo "OK"
  fi
  ok
}

function require_node() {
  NODE_BRANCH=node_12.x
  message "Checking node requirement"
  running "node -v"
  node -v
  if [[ $? != 0 ]]
  then
    action "node not found, installing via apt"
    running "apt-key"
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
    running "add-apt-repository https://deb.nodesource.com/${NODE_BRANCH} $(lsb_release -sc) main"
    sudo add-apt-repository --yes --no-update "deb https://deb.nodesource.com/${NODE_BRANCH} $(lsb_release -sc) main" &>/dev/null && echo "OK"
    running "apt -qq update"
    sudo apt-get -qq update && echo "OK"
    running "apt install nodejs"
    sudo DEBIAN_FRONEND=noninterractive apt-get install -qq --yes nodejs </dev/null >/dev/null && echo "OK"
  fi
  ok
}
