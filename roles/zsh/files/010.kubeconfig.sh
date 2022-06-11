#!/bin/bash

config=$HOME/.kube/config

# If there's already a kubeconfig file in ~/.kube/config it will import that too and all the contexts
if test -f "$config"
then
  export KUBECONFIG="$config"

  # Backup config file
  cp -fp "${config}" "${config}.bak"
fi

for c in "$config"-*
do
  export KUBECONFIG="$c:$KUBECONFIG"
done

kubectl config view --flatten >"${config}.new"
if ! cmp "${config}.new" "${config}.bak" >/dev/null 2>&1
then
  mv -f "${config}.new" "${config}"
fi
rm -f "${config}.bak" "${config}.new"
sed -i 's/^current-context:.*/current-context: homelab/' "${config}"

chmod 600 "${config}"

export KUBECONFIG="$config"

unset config
unset c
