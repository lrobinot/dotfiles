#!/bin/bash

#set -x

for package in $(cat inventory | yq '.all.vars.packages' | yq -r 'keys[]')
do
  repo=$(cat inventory | yq -r .all.vars.packages.$package.repo)
  platform=$(cat inventory | yq -r .all.vars.packages.$package.platform)
  if [ $repo != 'null' ]
  then
    version=$(cat inventory | yq -r .all.vars.packages.$package.version)
    latest_version=$(curl -Ls "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[].browser_download_url' | grep $platform | sed -e 's@^.*download/v@@' -e 's@/.*$@@' | head -1)

    if [ "$version" != "$latest_version" ]
    then
      echo ">>> $package should be upgraded from $version to $latest_version"
    else
      echo "$package is on latest version $version"
    fi
  fi
done
