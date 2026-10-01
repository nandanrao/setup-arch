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

######## Partitions

# fdisk -l
# fdisk /dev/DISK
# create BIOS boot 1M
# create EFI System 256M
# create Linux filesystem Rest

####### LUKS + Volumes

# cryptsetup -y luksFormat /dev/DISK/THE_PARTITION
# cryptsetup open /dev/DISK/THE_PARTITION cryptlvm
# pvcreate /dev/mapper/cryptlvm
# vgcreate VolumeGroup /dev/mapper/cryptlvm
# SWAP SIZING -- READ THIS BEFORE PICKING A NUMBER.
# Make swap at least 2x RAM. NOT "RAM + a bit".
#
# systemd refuses to hibernate unless
#     Active(anon) <= (SwapTotal - SwapUsed) * 0.98
# checked against the SINGLE swap area matching /sys/power/resume -- it does
# not sum swap areas. A 24G swap LV on a 24G-RAM machine passes this on a
# fresh boot and then quietly stops passing as the session ages and swap
# fills, because it is squeezed from both sides at once.
#
# When that check fails everything degrades SILENTLY:
#   - logind's suspend-then-hibernate falls back to plain suspend
#   - UPower's CriticalPowerAction walks HybridSleep -> Hibernate -> PowerOff
# so a laptop that runs out of battery is simply powered off, losing the
# session. This cost a 22-day session on 2026-09-02; see hibernation.md.
#
#   RAM_GB=$(awk '/MemTotal/{printf "%d", $2/1048576}' /proc/meminfo)
#   lvcreate -L $((RAM_GB * 2))G VolumeGroup -n swap
# lvcreate -l 100%FREE VolumeGroup -n root
# mkfs.ext4 /dev/VolumeGroup/root
# mkswap /dev/VolumeGroup/swap
# mount /dev/VolumeGroup/root /mnt
# swapon /dev/VolumeGroup/swap

####### INSTALL

# EDIT:
# /etc/pacman.d/mirrorlist

# pacstrap /mnt base linux linux-firmware nano grub lvm2 intel-ucode iwd networkmanager

# follow install instructions


echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "nandan" > /etc/hostname

####### SETUP MKINITCPIO

# hooks to /etc/mkinitcpio.conf
# HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 resume fsck filesystems)

####### SETUP BOOT LOADER

# Get device ID
# fdisk -f
# efibootmgr --disk /dev/DISK --part DISK_PARTITION --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'cryptdevice=UUID=[]:root:allow-discards root=/dev/Group/root resume=/dev/Group/swap initrd=\intel-ucode.img rw initrd=\initramfs-linux.img' --verbose
#
# resume=/dev/Group/swap is what makes hibernation target the swap LV. It is
# correct ONLY if that LV was sized per the note above. Verify after first
# boot, and again after a few days of uptime (a fresh boot always passes):
#
#   systemctl service-log-level systemd-logind debug
#   busctl call org.freedesktop.login1 /org/freedesktop/login1 \
#     org.freedesktop.login1.Manager CanHibernate          # want "yes"
#   journalctl -b0 -u systemd-logind --since -20s | grep Detected
#   systemctl service-log-level systemd-logind info
#
# The Detected line prints the size systemd actually chose -- confirm it is
# the swap LV. Then test for real: `systemctl hibernate`, power on, check the
# session came back. Ongoing canary, should stay silent:
#   journalctl -b0 | grep "operation is not supported"

###### CREATE USER
# useradd -m nandan
# passwd nandan
# usermod -aG wheel nandan
# visudo - uncomment wheel
