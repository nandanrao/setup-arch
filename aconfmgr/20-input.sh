# Keyboard remapping: keyd below xkb, custom 'nandan' xkb rules

AddPackage evtest # Input device event monitor and query tool
AddPackage keyd # A key remapping daemon for linux
AddPackage --foreign ltunify # Tool for working with Logitech Unifying receivers and devices
CopyFile /etc/keyd/default.conf
CreateLink /etc/systemd/system/multi-user.target.wants/keyd.service /usr/lib/systemd/system/keyd.service
CopyFile /usr/share/xkeyboard-config-2/rules/nandan
CopyFile /usr/share/xkeyboard-config-2/symbols/nandan
