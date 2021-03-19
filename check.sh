#!/bin/bash

top=$(git rev-parse --show-toplevel)

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
  /bin/echo -e "${COL_YELLOW} ⇒ ${COL_RESET}${1}"
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

VERSION=2.0+$(git rev-list --all --count)-g$(git rev-parse --short HEAD)
if ! git diff-index --quiet HEAD --
then
  VERSION="${VERSION}-dirty"
fi

clear
{
  figlet "dotfile++"
  echo "    v${VERSION}"
  echo ''
} | lolcat

for role in roles/*
do
  if [ -f "${role}/vars/main.yml" ]
  then
    repo=$(yq r "${role}/vars/main.yml" 'repo')
    version=$(yq r "${role}/vars/main.yml" 'version')
    if [ -n "${repo}" ]
    then
      latest=$(http "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name' | sed 's@^.*/@@')
      latest="${latest:1}"
      if [ "${version}" != "${latest}" ]
      then
        running "[$(basename "${role}")] ${repo} ${version} ${COL_RED}new version ${latest} available${COL_RESET} 👉 https://github.com/${repo}/releases/tag/v${latest}"
      else
        running "[$(basename "${role}")] ${repo} ${version} ${COL_GREEN}latest version${COL_RESET}"
      fi
    fi
  fi
done
