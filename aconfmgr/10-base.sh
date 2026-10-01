# Base system: kernel, boot, pacman, locale, networking core

AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage efibootmgr # Linux user-space application to modify the EFI Boot Manager
AddPackage intel-ucode # Microcode update files for Intel CPUs
AddPackage iptables # Linux kernel packet control tool (using nft interface)
AddPackage iwd # Internet Wireless Daemon
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux - Default set
AddPackage linux-firmware-nvidia  # REVIEW: only needed if the laptop has an NVIDIA GPU
AddPackage lvm2 # Logical Volume Manager 2 utilities
AddPackage man-db # A utility for reading man pages
AddPackage nano # Pico editor clone with enhancements
AddPackage networkmanager # Network connection manager and user applications
AddPackage ntp  # REVIEW: ntpd AND systemd-timesyncd are both enabled; keep one
AddPackage pacman-contrib # Contributed scripts and tools for pacman systems
AddPackage reflector # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.
AddPackage sudo # Give certain users the ability to run some commands as root
AddPackage which # A utility to show the full path of commands
AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux
AddPackage --foreign paru # Feature packed AUR helper
CopyFile /etc/hostname
CopyFile /etc/hosts
CreateDir /etc/iwd
CopyFile /etc/locale.conf
CopyFile /etc/locale.gen
CreateLink /etc/localtime ../usr/share/zoneinfo/America/New_York
CopyFile /etc/mkinitcpio.conf
CopyFile /etc/pacman.conf
CopyFile /etc/pacman.d/mirrorlist
CopyFile /etc/sudoers
CreateLink /etc/systemd/system/autovt@.service /usr/lib/systemd/system/getty@.service
CreateLink /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service /usr/lib/systemd/system/NetworkManager-dispatcher.service
CreateLink /etc/systemd/system/dbus-org.freedesktop.timesync1.service /usr/lib/systemd/system/systemd-timesyncd.service
CreateLink /etc/systemd/system/getty.target.wants/getty@tty1.service /usr/lib/systemd/system/getty@.service
CreateLink /etc/systemd/system/multi-user.target.wants/NetworkManager.service /usr/lib/systemd/system/NetworkManager.service
CreateLink /etc/systemd/system/multi-user.target.wants/ntpd.service /usr/lib/systemd/system/ntpd.service
CreateLink /etc/systemd/system/multi-user.target.wants/remote-fs.target /usr/lib/systemd/system/remote-fs.target
CreateLink /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service /usr/lib/systemd/system/NetworkManager-wait-online.service
CreateLink /etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service /usr/lib/systemd/system/systemd-timesyncd.service
CreateLink /etc/systemd/system/timers.target.wants/paccache.timer /usr/lib/systemd/system/paccache.timer
CopyFile /etc/vconsole.conf
SetFileProperty / mode 555  # REVIEW: Arch default is 755; harmless either way
