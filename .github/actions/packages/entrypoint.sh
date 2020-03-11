#!/usr/bin/env bash
set -euxo pipefail

pwd
cd /home/builduser

echo "Importing GPG keys"
# Strip out comments before importing keys
grep -o '^[^#]*' /github/workspace/gpg_keys.txt | xargs -I '{}' gpg --recv-keys '{}'

echo "Adding custom repository to Pacman configuration"
mkdir repo
repo-add repo/personal.db.tar
sudo tee -a /etc/pacman.conf > /dev/null <<EOT
[personal]
SigLevel = Optional TrustAll
Server = file:///home/builduser/repo
EOT

echo "Installing aurutils"
sudo pacman --noconfirm -Syu git
git clone https://aur.archlinux.org/aurutils.git
cd aurutils
gpg --recv-keys 6BC26A17B9B7018A # aurutils maintainer key
makepkg --noconfirm -si

echo "Use aurutils to sync packages"
# Strip out comments before syncing pacakges
grep -o '^[^#]*' /github/workspace/gpg_keys.txt | xargs -I '{}' aur sync --noconfirm --noview '{}'
