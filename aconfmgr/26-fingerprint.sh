# Fingerprint login. The driver depends on the sensor, so this checks the USB devices
# on whatever machine it runs on:
#   - python-validity for the few old Synaptics/Validity sensors it supports (that
#     project's own list; the T480s has 06cb:009a)
#   - plain fprintd for everything else (Goodix on the T14s, most modern sensors)
# On a laptop without a reader, fprintd just finds no device and PAM skips it.

validity_sensor=no
for dev in /sys/bus/usb/devices/*/; do
	[[ -f $dev/idVendor ]] || continue
	case "$(<"$dev/idVendor"):$(<"$dev/idProduct")" in
		06cb:009a|138a:0090|138a:0097|138a:009d) validity_sensor=yes ;;
	esac
done

if [[ $validity_sensor == yes ]]; then
	AddPackage --foreign python-validity # Validity fingerprint sensor driver
	# python-validity's sensor needs resetting after sleep
	CreateLink /etc/systemd/system/hibernate.target.wants/python3-validity-suspend-hotfix.service /usr/lib/systemd/system/python3-validity-suspend-hotfix.service
	CreateLink /etc/systemd/system/hybrid-sleep.target.wants/python3-validity-suspend-hotfix.service /usr/lib/systemd/system/python3-validity-suspend-hotfix.service
	CreateLink /etc/systemd/system/suspend-then-hibernate.target.wants/python3-validity-suspend-hotfix.service /usr/lib/systemd/system/python3-validity-suspend-hotfix.service
	CreateLink /etc/systemd/system/suspend.target.wants/python3-validity-suspend-hotfix.service /usr/lib/systemd/system/python3-validity-suspend-hotfix.service
else
	AddPackage fprintd # D-Bus service to access fingerprint readers
fi

# Fingerprint as an alternative to the password at login and unlock (pam_fprintd)
CopyFile /etc/pam.d/login
CopyFile /etc/pam.d/swaylock
CopyFile /etc/pam.d/system-local-login
