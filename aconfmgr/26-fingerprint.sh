# Fingerprint login. python-validity is for THIS laptop's Synaptics sensor (06cb:009a);
# a different laptop probably uses plain fprintd instead.

AddPackage --foreign python-validity # Validity fingerprint sensor driver
CopyFile /etc/pam.d/login
CopyFile /etc/pam.d/swaylock
CopyFile /etc/pam.d/system-local-login
CreateLink /etc/systemd/system/hibernate.target.wants/python3-validity-suspend-hotfix.service /usr/lib/systemd/system/python3-validity-suspend-hotfix.service
CreateLink /etc/systemd/system/hybrid-sleep.target.wants/python3-validity-suspend-hotfix.service /usr/lib/systemd/system/python3-validity-suspend-hotfix.service
CreateLink /etc/systemd/system/suspend-then-hibernate.target.wants/python3-validity-suspend-hotfix.service /usr/lib/systemd/system/python3-validity-suspend-hotfix.service
CreateLink /etc/systemd/system/suspend.target.wants/python3-validity-suspend-hotfix.service /usr/lib/systemd/system/python3-validity-suspend-hotfix.service
