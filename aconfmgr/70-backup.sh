# Borg backup to BorgBase: runs as root, see README 'Backup'

AddPackage borg # Deduplicating backup program with compression and authenticated encryption
CopyFile /etc/systemd/system/borg-check.service
CopyFile /etc/systemd/system/borg-check.timer
CopyFile /etc/systemd/system/borg-failure-notify@.service
CopyFile /etc/systemd/system/borg-notify-selftest.service
CopyFile /etc/systemd/system/borg.service
CopyFile /etc/systemd/system/borg.service.d/50-onfailure.conf
CopyFile /etc/systemd/system/borg.timer
CreateLink /etc/systemd/system/timers.target.wants/borg-check.timer /etc/systemd/system/borg-check.timer
CreateLink /etc/systemd/system/timers.target.wants/borg.timer /etc/systemd/system/borg.timer
CopyFile /usr/local/bin/borg-failure-notify 755
CopyFile /usr/local/sbin/borg-backup.sh 755
CopyFile /usr/local/sbin/borg-check.sh 755
