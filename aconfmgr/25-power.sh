# Power and hibernation. Read hibernation.md before touching this.

AddPackage acpi # Client for battery, power, and thermal readings
AddPackage --foreign light # A program to control backlights (and other hardware lights)
CopyFile /etc/UPower/UPower.conf
CopyFile /etc/systemd/homed.conf
CreateDir /etc/systemd/logind.conf.d
CopyFile /etc/systemd/logind.conf.d/10-hibernate.conf
CreateDir /etc/systemd/sleep.conf.d
CopyFile /etc/systemd/sleep.conf.d/10-hibernate.conf
