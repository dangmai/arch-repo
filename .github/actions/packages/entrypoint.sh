#!/usr/bin/env bash
set -euxo pipefail

cd /home/builduser

# Github set the HOME variable to /github/home, which the builduser does not have write access to,
# which leads to gpg importing errors
export HOME=/home/builduser
# Use Zst as the compression method, it is much faster than the default.
export PKGEXT='.pkg.tar.zst'

echo "Importing GPG keys"
# Manually getting Spotify key
curl -sS https://download.spotify.com/debian/pubkey.gpg | gpg --import -
# Strip out comments before importing keys
grep -o '^[^#]*' /github/workspace/gpg_keys.txt | xargs -I '{}' gpg --recv-keys '{}'

echo "Installing aurutils"
sudo pacman --noconfirm -Syu git cadaver
git clone https://aur.archlinux.org/aurutils.git
cd aurutils
makepkg --noconfirm -si

echo "Adding custom repository to Pacman configuration"
cd /home/builduser
sudo tee -a /etc/pacman.conf > /dev/null <<EOT
[personal]
SigLevel = Optional TrustAll
Server = file:///home/builduser/repo
EOT
mkdir repo
echo "Downloading current repository"
cd repo
cadaver <<EOF
open ${WEBDAV_URL}
cd repo/
mget *
quit
EOF
if [[ -f "personal.db.tar" ]]; then
  rm personal.db
  ln -s personal.db.tar personal.db
  rm personal.files
  ln -s personal.files.tar personal.files
  echo "Downloading repository succeeded!"
else
  repo-add personal.db.tar
fi
sudo pacman --noconfirm -Sy

echo "Sync packages using aurutils"
# Strip out comments before syncing packages
# Somehow the -L flag is necessary here for aur sync (it passes it to `makepkg`),
# without it bsdtar cannot compress the package properly
grep -o '^[^#]*' /github/workspace/aur_packages.txt | xargs -I '{}' aur sync -L --noconfirm --noview '{}'

echo "Copying artifacts to workspace"
sudo cp -R /home/builduser/repo /github/workspace/