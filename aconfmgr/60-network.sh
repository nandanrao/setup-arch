# VPNs, tailscale, tor, ssh

AddPackage bind # A complete, highly portable implementation of the DNS protocol
AddPackage networkmanager-openvpn # NetworkManager VPN plugin for OpenVPN (with GUI)
AddPackage openfortivpn # An open implementation of Fortinet's proprietary PPP+SSL VPN solution
AddPackage openvpn # An easy-to-use, robust and highly configurable VPN (Virtual Private Network)
AddPackage ppp # A daemon which implements the Point-to-Point Protocol for dial-up networking
AddPackage tailscale # A mesh VPN that makes it easy to connect your devices, wherever they are.
AddPackage tor # Anonymizing overlay network.
AddPackage torsocks # Wrapper to safely torify applications
AddPackage --foreign mullvad-vpn-bin # The Mullvad VPN client app for desktop (desktop application)
CopyFile /etc/modprobe.d/modules.conf
CreateDir /etc/openvpn/client 750 openvpn network
CreateDir /etc/openvpn/server 750 openvpn network
CreateLink /etc/systemd/system/mullvad-daemon.service.wants/mullvad-early-boot-blocking.service /usr/lib/systemd/system/mullvad-early-boot-blocking.service
CreateLink /etc/systemd/system/multi-user.target.wants/mullvad-daemon.service /usr/lib/systemd/system/mullvad-daemon.service
CreateLink /etc/systemd/system/multi-user.target.wants/sshd.service /usr/lib/systemd/system/sshd.service
CreateLink /etc/systemd/system/multi-user.target.wants/tailscaled.service /usr/lib/systemd/system/tailscaled.service
