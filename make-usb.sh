#!/usr/bin/env bash
# Build the installer USB stick: the Arch ISO's files plus a copy of this repo,
# on an ordinary writable FAT32 stick (UEFI boot only).
#
#     ./make-usb.sh ~/Downloads/archlinux-YYYY.MM.DD-x86_64.iso /dev/sdX
#
# Booted, the stick shows up at /run/archiso/bootmnt, so the installer is:
#     bash /run/archiso/bootmnt/setup-arch/install.sh /dev/nvme0n1
#
# Get the ISO from https://archlinux.org/download/ and verify it first:
#     pacman-key -v archlinux-YYYY.MM.DD-x86_64.iso.sig
#
# If the stick won't boot, fall back to the plain method (stick becomes read-only,
# so carry this repo another way):
#     sudo dd if=archlinux.iso of=/dev/sdX bs=4M status=progress oflag=sync
set -euo pipefail

ISO=${1:?usage: make-usb.sh ISO /dev/sdX}
DEV=${2:?usage: make-usb.sh ISO /dev/sdX}
REPO=$(cd "$(dirname "$0")" && pwd)

[[ -f $ISO ]] || { echo "No such ISO: $ISO"; exit 1; }
[[ $(lsblk -dno TRAN "$DEV") == usb ]] || { echo "$DEV is not a USB drive"; exit 1; }

# The FAT label must match the ISO's label (e.g. ARCH_202610).
LABEL=$(blkid -s LABEL -o value "$ISO")

lsblk -o NAME,SIZE,MODEL,MOUNTPOINTS "$DEV"
echo
echo "This ERASES $DEV and writes $(basename "$ISO") + $REPO to it (label $LABEL)."
read -rp "Type YES to continue: " ok
[[ $ok == YES ]] || exit 1

# Unmount anything the desktop auto-mounted from it.
for part in $(lsblk -lno PATH "$DEV" | tail -n +2); do sudo umount "$part" 2>/dev/null || true; done

sudo wipefs --all "$DEV"
sudo sgdisk --zap-all -n1:0:0 -t1:ef00 "$DEV"
sudo partprobe "$DEV"; sleep 2
PART=$(lsblk -lno PATH "$DEV" | sed -n 2p)
sudo mkfs.fat -F32 -n "$LABEL" "$PART"

MNT=$(mktemp -d)
sudo mount "$PART" "$MNT"
sudo bsdtar -x -f "$ISO" -C "$MNT"
sudo git clone --quiet "$REPO" "$MNT/setup-arch"
sync
sudo umount "$MNT"
rmdir "$MNT"
echo "USB ready."
