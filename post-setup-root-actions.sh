# GROUPS
sudo usermod -aG docker $USER
sudo usermod -aG video $USER

# systemctl
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now docker
sudo systemctl enable --now bluetooth
sudo systemctl enable --now snapd.socket
sudo systemctl enable --now ntpd

sudo ln -s /var/lib/snapd/snap /snap

# UPF VPN
# create if not exists
sudo echo "alias char-major-108 ppp_generic" > /etc/modprobe.d/modules.conf

# Pulse audio switch on connect 
echo "\n# automatically switch to newly-connected devices\nload-module module-switch-on-connect" | sudo tee -a /etc/pulse/default.pa

# Setup xkb for i3
# Sourced from this repo rather than ~/.xkb so a fresh machine works -- the
# custom keymap is what gives caps->ctrl, right shift->Alt, compose on right
# alt and print/fn->Super. Without these files sway's xkb_rules "nandan"
# fails to compile and the whole layout silently reverts to plain us.
sudo cp 40-custom.conf /etc/X11/xorg.conf.d/
sudo cp user-share-X11-xkb/rules/nandan* /usr/share/X11/xkb/rules/
sudo cp user-share-X11-xkb/symbols/nandan /usr/share/X11/xkb/symbols/

# keyd -- key remapping below xkb, for the Lenovo Go Wireless Split only.
# Scoped to that receiver's vendor:product (17ef:6116), so no other keyboard
# is affected. Two things live in it, both explained in the config file:
#   - its Copilot key sends the chord LeftShift+LeftMeta+F23 rather than a
#     modifier; keyd collapses that to a plain Super
#   - right shift -> Alt, which xkb stopped applying once keyd began
#     re-emitting through its own virtual device
# While keyd runs, that keyboard reaches sway as 4012:2782:keyd_virtual_keyboard.
# `sudo systemctl stop keyd` reverts all of it.
sudo install -Dm644 etc-keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd

# Hibernation. Lid/idle go to suspend-then-hibernate and UPower hibernates
# instead of powering off at critical battery.
#
# These configs are necessary but NOT sufficient: they are inert unless the
# swap LV is >= 2x RAM. systemd checks Active(anon) against free swap on the
# one area matching /sys/power/resume, and when that fails BOTH paths degrade
# silently -- logind drops to plain suspend, UPower falls through
# HybridSleep -> Hibernate -> PowerOff. See initial-crypted-swap.sh (sizing)
# and hibernation.md (the incident this came from).
sudo install -Dm644 etc-systemd/logind.conf.d/10-hibernate.conf /etc/systemd/logind.conf.d/10-hibernate.conf
sudo install -Dm644 etc-systemd/sleep.conf.d/10-hibernate.conf /etc/systemd/sleep.conf.d/10-hibernate.conf
sudo install -Dm644 UPower.conf /etc/UPower/UPower.conf
# Takes effect on next boot. Restarting systemd-logind would end the session.
