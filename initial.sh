####### WIPING

# cryptsetup open --type plain -d /dev/urandom /dev/<block-device> to_be_wiped

####### VERIFY:
# lsblk
# NAME          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
# sda             8:0    0  1.8T  0 disk
# └─to_be_wiped 252:0    0  1.8T  0 crypt

####### WIPE:
# dd bs=1M if=/dev/zero of=/dev/mapper/to_be_wiped status=progress

# sync
# rm /file/in/container

# create partitions (boot, root)

# fdisk -l

# fdisk /dev/sda
# create /boot - +256M
# n
#
# create / - rest
#

####### ROOT PARTITION

# cryptsetup -y -v luksFormat /dev/sda2
# cryptsetup open /dev/sda2 cryptroot
# mkfs.ext4 /dev/mapper/cryptroot
# mount /dev/mapper/cryptroot /mnt

# umount /mnt
# cryptsetup close cryptroot
# cryptsetup open /dev/sda2 cryptroot
# mount /dev/mapper/cryptroot /mnt

####### BOOT PARTITION
# mkfs.ext4 /dev/sda1
# mkdir /mnt/boot
# mount /dev/sda1 /mnt/boot


####### INSTALL

# EDIT:
# /etc/pacman.d/mirrorlist

# pacstrap /mnt base linux linux-firmware nano grub

# follow install instructions

# BOOT LOADER
# grub-install --target=i386-pc /dev/sda

# SETUP MKINITCPIO

# hooks to /etc/mkinitcpio.conf
# HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)


####### SETUP GRUB
# /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT

# root=/dev/mapper/cryptroot
# Get device ID
# ls -l /dev/disk/by-id
#
# cryptdevice=UUID=device-UUID:cryptroot:allow-discards root=/dev/mapper/cryptroot
