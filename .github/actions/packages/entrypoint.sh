#!/usr/bin/env bash
set -euxo pipefail

cd /home/builduser

# Github set the HOME variable to /github/home, which the builduser does not have write access to,
# which leads to gpg importing errors
export HOME=/home/builduser
# Use Zst as the compression method, it is much faster than the default.
export PKGEXT='.pkg.tar.zst'

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
makepkg --noconfirm -si

echo "Sync packages using aurutils"
# Strip out comments before syncing packages
# Somehow the -L flag is necessary here for aur sync (it passes it to `makepkg`),
# without it bsdtar cannot compress the package properly
grep -o '^[^#]*' /github/workspace/aur_packages.txt | xargs -I '{}' aur sync -L --noconfirm --noview '{}'

echo "Renaming packages to workaround GitHub releases shortcoming"
# Github Releases do not support having colon (:) in file names -
# they automatically change it to a period, which makes the database incorrect.
# We will work around that by changing the package names before uploading to Github.
cd /home/build/user/repo
for package in *.tar.zst; do
  if [[ ${package} == *':'* ]]; then
    PACKAGE_NAME=${package/:/.}
    mv -- ${package} ${PACKAGE_NAME}
    repo-add personal.db.tar ${PACKAGE_NAME}
  fi
done

echo "Copying artifacts to workspace"
sudo cp -R /home/builduser/repo /github/workspace/