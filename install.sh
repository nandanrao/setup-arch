#!/usr/bin/env bash
# README step 1: install a bare, encrypted Arch onto DISK.
# Run from the Arch live USB, as root (see README step 1):
#
#     pacman -Sy git && git clone https://github.com/nandanrao/setup-arch
#     bash setup-arch/install.sh /dev/nvme0n1
#
# Layout: 1G EFI partition + LUKS -> LVM (swap = 2x RAM, root = the rest).
# Boots with EFISTUB (no bootloader): the kernel is started straight from a
# UEFI boot entry. Same as the old laptop.
set -euo pipefail

DISK=${1:?usage: install.sh /dev/DISK   (see lsblk)}
[[ -b $DISK ]] || { echo "$DISK is not a disk"; exit 1; }
[[ -d /sys/firmware/efi ]] || { echo "Not booted in UEFI mode. Check BIOS settings."; exit 1; }
ping -c1 -W3 archlinux.org >/dev/null || { echo "No internet. Wi-Fi: iwctl station wlan0 connect NAME"; exit 1; }

# nvme0n1 -> nvme0n1p1, sda -> sda1
case $DISK in *[0-9]) P=${DISK}p ;; *) P=$DISK ;; esac
ESP=${P}1
LUKS=${P}2

# Swap must be >= 2x RAM or hibernation silently stops working. See hibernation.md.
RAM_GB=$(awk '/MemTotal/{printf "%d", ($2 + 1048575) / 1048576}' /proc/meminfo)
SWAP_GB=$((RAM_GB * 2))

lsblk "$DISK"
echo
echo "This ERASES $DISK: ${SWAP_GB}G swap (RAM is ${RAM_GB}G), rest is root."
read -rp "Type YES to continue: " ok
[[ $ok == YES ]] || exit 1

### Partitions
sgdisk --zap-all "$DISK"
sgdisk -n1:0:+1G -t1:ef00 -n2:0:0 -t2:8309 "$DISK"
partprobe "$DISK"; sleep 2
mkfs.fat -F32 "$ESP"

### Encryption + volumes. You'll be asked for the new disk passphrase, then again to open it.
cryptsetup luksFormat "$LUKS"
cryptsetup open "$LUKS" root
pvcreate /dev/mapper/root
vgcreate Group /dev/mapper/root
lvcreate -L "${SWAP_GB}G" Group -n swap
lvcreate -l 100%FREE Group -n root
mkfs.ext4 /dev/Group/root
mkswap /dev/Group/swap

mount /dev/Group/root /mnt
mount --mkdir "$ESP" /mnt/boot
swapon /dev/Group/swap

### Base system
# Microcode for this machine's CPU (aconfmgr/10-base.sh picks the same way).
if grep -q GenuineIntel /proc/cpuinfo; then UCODE=intel-ucode; else UCODE=amd-ucode; fi

pacstrap -K /mnt base base-devel linux linux-firmware $UCODE lvm2 \
    networkmanager iwd efibootmgr sudo nano zsh git
genfstab -U /mnt >> /mnt/etc/fstab

### Inside the new system
UUID=$(blkid -s UUID -o value "$LUKS")
arch-chroot /mnt /bin/bash -e <<EOF
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'KEYMAP=us' > /etc/vconsole.conf
echo nandan > /etc/hostname

# Same hooks as the old laptop; aconfmgr later installs the identical mkinitcpio.conf.
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 resume fsck filesystems)/' /etc/mkinitcpio.conf
mkinitcpio -P

efibootmgr --create --disk $DISK --part 1 --label "Arch Linux" --loader '\vmlinuz-linux' \
  --unicode 'cryptdevice=UUID=$UUID:root:allow-discards root=/dev/Group/root resume=/dev/Group/swap rw initrd=\\${UCODE}.img initrd=\initramfs-linux.img'

useradd -m -G wheel -s /bin/zsh nandan
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
visudo -c
systemctl enable NetworkManager
EOF

echo "Password for root:"
arch-chroot /mnt passwd
echo "Password for nandan:"
arch-chroot /mnt passwd nandan

umount -R /mnt
echo
echo "Done. Remove the USB stick and run: reboot"
echo "Then continue with README step 1's last paragraph (log in as root)."
