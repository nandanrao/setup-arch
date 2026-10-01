# Power and hibernation. Read hibernation.md before touching this.

AddPackage acpi # Client for battery, power, and thermal readings
AddPackage --foreign light # A program to control backlights (and other hardware lights)
CopyFile /etc/UPower/UPower.conf
CopyFile /etc/systemd/homed.conf
CopyFile /etc/systemd/logind.conf
CopyFile /etc/systemd/sleep.conf
