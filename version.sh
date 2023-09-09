#!/bin/bash

top=$(git rev-parse --show-toplevel)

#set -x
set -e

VERSION=2.1
VERSION="${VERSION}.$(git rev-list --all --count)-$(git rev-parse --short HEAD)"
if ! git diff-index --quiet HEAD --
then
  VERSION="${VERSION}-dirty"
fi
echo "${VERSION}"
