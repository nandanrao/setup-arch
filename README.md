# Arch setup

How to turn a blank laptop into my laptop.

- **System** (packages, `/etc`, services) lives here, in `aconfmgr/`.
- **Everything in `/home/nandan`** comes back from the borg backup on BorgBase.

Shortcut used below: `acm` = `aconfmgr -c ~/Documents/setup-arch/aconfmgr`
(the alias is in `~/.zshrc`, so it works once home is restored).


## 0. Before you start

Keep these somewhere you can open **from your phone** (a password manager whose
vault is not only on this laptop): the borg passphrase, your BorgBase login and
2FA, the Wi-Fi password. You'll also choose a new disk passphrase during install.

On the old laptop, if you still have it:

1. `acm save` says "configuration unchanged". Commit and push.
2. Run a fresh backup and wait for "finished successfully":
   ```
   sudo systemctl start borg.service
   journalctl -fu borg.service
   ```

Make the USB stick. It is just the plain Arch installer; this repo comes from
GitHub later. Use a spare stick: it gets erased.

1. Download `archlinux-YYYY.MM.DD-x86_64.iso` from https://archlinux.org/download/
2. Check its SHA256 against the one on that page.
   Windows (PowerShell, in the download folder): `Get-FileHash .\archlinux-*.iso`
   Linux: `sha256sum archlinux-*.iso`
3. Write it to the stick.
   Windows: [Rufus](https://rufus.ie), GPT + UEFI, and pick **DD Image mode** when asked.
   Linux: `sudo dd if=archlinux-*.iso of=/dev/sdX bs=4M status=progress oflag=sync`


## 1. Install Arch

1. If the laptop has Windows on it: shut down with **Shift + Shut down**
   (a plain shutdown only hibernates and can upset the installer).
2. In the BIOS (F1 at boot): turn **off** Secure Boot.
3. Boot the stick (F12 at boot → the USB drive). You get a `root@archiso` prompt.
4. Check you booted in UEFI mode: `ls /sys/firmware/efi` must list files.
5. Wi-Fi, then check it works:
   ```
   iwctl station wlan0 connect "NETWORK"
   ping -c3 archlinux.org
   ```
6. Get this repo (git isn't on the installer, so install it first) and run the
   installer. Find the disk with `lsblk` (probably `nvme0n1`). It asks you to type
   YES before wiping, then for the disk passphrase and the two user passwords.
   Read `install.sh` to see exactly what it does.
   ```
   pacman -Sy git
   git clone https://github.com/nandanrao/setup-arch
   bash setup-arch/install.sh /dev/nvme0n1
   reboot                                   # and remove the stick
   ```
7. Log in as **root** on the text console (not nandan: we're about to overwrite
   nandan's home). Wi-Fi: `nmcli device wifi connect "NETWORK" password "PASSWORD"`


## 2. Restore home from borg

### Give this laptop access to BorgBase

Your usual borg SSH key is inside the backup, so make a temporary one. It goes in
`/root`, because `/home/nandan` is about to be overwritten. Press Enter at both
passphrase prompts (no passphrase).

```
pacman -S borg openssh
ssh-keygen -t ed25519 -f /root/.ssh/borg_restore
```

Now get that key into BorgBase. There is no desktop yet, so either:

- **Phone:** `pacman -S qrencode && qrencode -t ansiutf8 < /root/.ssh/borg_restore.pub`,
  scan the QR code, and paste the text into BorgBase on the phone.
- **Firefox on this laptop**, full screen with the key already on the clipboard:
  ```
  pacman -S cage firefox wl-clipboard
  cage -- sh -c 'wl-copy < /root/.ssh/borg_restore.pub; firefox'
  ```
  Ctrl+V pastes it. Ctrl+Q quits back to the console.
  (No clipboard? Open `view-source:file:///root/.ssh/borg_restore.pub` in a tab
  and copy from there.)

In BorgBase it takes **two** steps:

1. Add the key (Account → SSH Keys → Add Key). It's one line starting `ssh-ed25519`.
2. Give it access to the repo: Repositories → the repo → Edit → **Access** →
   select the new key under full or append-only access → Save.
   **Skipping this gives "Permission denied (publickey)".**

`acm apply` in step 3 removes cage, qrencode and wl-clipboard again if they
aren't in the config.

### Restore

Everything below runs in the same console. If you open a new one (or leave and
re-enter cage), run the three setup lines again.

```
export BORG_REPO=ssh://faan3tku@faan3tku.repo.borgbase.com/./repo
export BORG_RSH="ssh -i /root/.ssh/borg_restore"
read -rs BORG_PASSPHRASE && export BORG_PASSPHRASE   # type the borg passphrase, Enter (nothing shows)

borg list                                # first time: answer "yes" to "authenticity of host"
```

`borg list` shows one line per backup ("archive"). The name is the first column,
e.g. `2026-10-03T00:59:49`, and the newest is at the bottom. Restore the newest.
This takes hours; leave it running.

```
A=$(borg list --last 1 --short) && echo $A
cd / && borg extract --progress ::$A home/nandan

# keep the old /etc nearby, for Wi-Fi passwords and other secrets
mkdir /root/old-etc && cd /root/old-etc && borg extract ::$A etc
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
