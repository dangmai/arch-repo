FROM dangmai/archlinux-devel:latest

COPY srcinfo-entrypoint.sh entrypoint.sh
COPY aur_packages.txt aur_packages.txt
COPY gpg_keys.txt gpg_keys.txt

ENTRYPOINT ["/home/builduser/entrypoint.sh"]