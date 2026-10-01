# Arch setup

How to turn a blank laptop into my laptop.

- **System** (packages, `/etc`, services) lives here, in `aconfmgr/`.
- **Everything in `/home/nandan`** comes back from the borg backup on BorgBase.

Shortcut used below: `acm` = `aconfmgr -c ~/Documents/setup-arch/aconfmgr`
(the alias is in `~/.zshrc`, so it works once home is restored).


## 0. Before you start (on the old laptop)

1. `acm save` says "configuration unchanged". Commit and push.
2. Run a fresh backup and wait for "finished successfully":
   ```
   sudo systemctl start borg.service
   journalctl -fu borg.service
   ```
3. Check you can log in to borgbase.com.
4. Have ready: borg passphrase, Wi-Fi password, a new disk passphrase.
5. Write the Arch ISO to a USB stick: `sudo dd if=archlinux.iso of=/dev/sdX bs=4M status=progress`


## 1. Install Arch

In the BIOS (F1 at boot): turn **off** Secure Boot. Boot the USB stick.

Wi-Fi: `iwctl station wlan0 connect "NETWORK"`

Check the disk name with `lsblk` (below assumes `nvme0n1`). **This wipes it.**

```
sgdisk --zap-all /dev/nvme0n1
sgdisk -n1:0:+1G -t1:ef00 -n2:0:0 -t2:8309 /dev/nvme0n1
mkfs.fat -F32 /dev/nvme0n1p1

cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 root
pvcreate /dev/mapper/root
vgcreate Group /dev/mapper/root
lvcreate -L 64G Group -n swap        # 2x RAM, or hibernation fails. See hibernation.md
lvcreate -l 100%FREE Group -n root
mkfs.ext4 /dev/Group/root
mkswap /dev/Group/swap

mount /dev/Group/root /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
swapon /dev/Group/swap

pacstrap -K /mnt base base-devel linux linux-firmware intel-ucode lvm2 \
    networkmanager iwd efibootmgr sudo nano zsh git
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

Inside the new system:

```
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo nandan > /etc/hostname

sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 resume fsck filesystems)/' /etc/mkinitcpio.conf
mkinitcpio -P

UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "Arch Linux" --loader '\vmlinuz-linux' \
  --unicode "cryptdevice=UUID=$UUID:root:allow-discards root=/dev/Group/root resume=/dev/Group/swap rw initrd=\intel-ucode.img initrd=\initramfs-linux.img"

passwd                                   # root password
useradd -m -G wheel -s /bin/zsh nandan
passwd nandan
EDITOR=nano visudo                       # uncomment: %wheel ALL=(ALL) ALL
systemctl enable NetworkManager

exit
umount -R /mnt
reboot
```

Log in as **root** on the text console (not nandan: we're about to overwrite
nandan's home). Wi-Fi: `nmcli device wifi connect "NETWORK" password "PASSWORD"`


## 2. Restore home from borg

Make a key for this laptop and add it in BorgBase
(Repositories → the repo → Edit → Access → add key):

```
pacman -S borg openssh
ssh-keygen -t ed25519 -f /root/.ssh/borg_restore
cat /root/.ssh/borg_restore.pub          # paste this into BorgBase
```

Then restore. This takes hours; leave it running.

```
export BORG_REPO=ssh://faan3tku@faan3tku.repo.borgbase.com/./repo
export BORG_RSH="ssh -i /root/.ssh/borg_restore"
borg list                                # pick the newest archive name
cd / && borg extract --progress ::ARCHIVE home/nandan

# keep the old /etc nearby, for Wi-Fi passwords and other secrets
mkdir /root/old-etc && cd /root/old-etc && borg extract ::ARCHIVE etc
cp -a /root/old-etc/etc/NetworkManager/system-connections/. /etc/NetworkManager/system-connections/
```

Log out. From now on, log in as **nandan**.


## 3. Rebuild the system

```
cd ~/Documents/setup-arch && git pull

git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si
paru -S aconfmgr-git
```

Two checks before applying:
- Fingerprint reader: if `lsusb | grep 138a:0097` prints nothing, this laptop has
  a different sensor. Delete `aconfmgr/26-fingerprint.sh`.
- No NVIDIA GPU? Delete the `linux-firmware-nvidia` line in `aconfmgr/10-base.sh`.

```
acm apply
```

It asks before each step. **Read the lists.** At "Deleting N files", press `d`
to see them first. If a step fails with "cannot remove … No such file", run
`acm apply` again.

Then:

```
sudo mkinitcpio -P
sudo usermod -aG docker,video nandan
reboot
```


## 4. Things aconfmgr doesn't do

- **Borg backups**: store the passphrase for the nightly job
  (type it, press Enter, then Ctrl-D):
  ```
  sudo sh -c 'umask 077; cat > /root/.borg-passphrase'
  sudo systemctl start borg.service && journalctl -fu borg.service
  ```
  Once that succeeds, **turn off backups on the old laptop**:
  `sudo systemctl disable --now borg.timer borg-check.timer`.
  Remove the `borg_restore` key from BorgBase.
- **Dropbox**: run `dropbox`, sign in, then exclude the folders right away
  (before it downloads everything):
  `cd ~/Dropbox && xargs -a ~/Documents/setup-arch/dropbox-exclude.txt dropbox exclude add`
- **VPNs**: `sudo tailscale up`, and log in to Mullvad.
- **TeX Live**: installed by hand, see `tex.sh`.
- **Node**: `~/.nvm` isn't backed up. `nvm install --lts`, then
  `npm install -g @marp-team/marp-cli typescript typescript-language-server`.


## 5. Check it worked

- `acm save` says "configuration unchanged". If it makes `99-unsorted.sh`,
  sort it into the group files and commit.
- Sound, Wi-Fi, Bluetooth, screen sharing, fingerprint.
- Hibernate for real: `sudo systemctl hibernate`, power on, the session comes back.
  Read `hibernation.md`; check again after a few days of uptime.
- The next morning: `journalctl -u borg.service` shows last night's backup succeeded.

Keep the old laptop untouched for a week or two.


## Day to day

- **Install**: `paru -S foo`, then `acm save`, move the line from
  `99-unsorted.sh` into a group file, commit.
- **Remove**: `sudo pacman -Rns foo` (shows everything that goes), then `acm save`,
  delete the line, commit.
- **Change a file in /etc**: `sudoedit /etc/...`, then `acm save`, commit.
- **Only run `acm apply`** on a new machine, or after editing this repo by hand.
  Run `acm save` first; if it makes a `99-unsorted.sh`, sort that first.
- Once a week: `acm save`. "configuration unchanged" means all is well.
