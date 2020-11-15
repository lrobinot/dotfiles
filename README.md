# My little dotfiles collection, and more.

## Create ssh keypair for root user

```
sudo ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
sudo cat /root/.ssh/id_rsa.pub |& sudo tee -a /root/.ssh/authorized_keys
```

## Install basic requirements

```
sudo apt install ansible git openssh-server
git clone --recursive git@github.com:lrobinot/dotfiles.git
```

## Install Tools, Settings, etc ...

```
cd dotfiles
./setup.sh
```

## Chrome Setup

1. Install Bitwarden extension
2. Sync Chrome
