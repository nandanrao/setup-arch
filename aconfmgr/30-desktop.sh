# Sway desktop, audio, fonts, session services

AddPackage adobe-source-code-pro-fonts # Monospaced font family for user interface and coding environments
AddPackage alacritty # A cross-platform, GPU-accelerated terminal emulator
AddPackage alsa-utils # Advanced Linux Sound Architecture - Utilities
AddPackage bemenu # Dynamic menu library and client program inspired by dmenu
AddPackage bluetui # TUI for managing bluetooth devices
AddPackage bluez-utils # Development and debugging utilities for the bluetooth protocol stack
AddPackage dmenu # Generic menu for X
AddPackage grim # Screenshot utility for Wayland
AddPackage network-manager-applet # Applet for managing network connections
AddPackage nm-connection-editor # NetworkManager GUI connection editor and widgets
AddPackage pango # A library for layout and rendering of text
AddPackage pavucontrol # PulseAudio Volume Control
AddPackage pulseaudio-alsa # ALSA Configuration for PulseAudio
AddPackage pulseaudio-bluetooth # Bluetooth support for PulseAudio
AddPackage rofi # A window switcher, application launcher and dmenu replacement
AddPackage slurp # Select a region in a Wayland compositor
AddPackage swappy # A Wayland native snapshot editing tool
AddPackage sway # Tiling Wayland compositor and replacement for the i3 window manager
AddPackage swayidle # Idle management daemon for Wayland
AddPackage swaylock # Screen locker for Wayland
AddPackage udiskie # Removable disk automounter using udisks
AddPackage udisks2 # Daemon, tools and libraries to access and manipulate disks, storage devices and technologies
AddPackage waybar # Highly customizable Wayland bar for Sway and Wlroots based compositors
AddPackage wl-clipboard # Command-line copy/paste utilities for Wayland
AddPackage wtype # xdotool type for wayland
AddPackage xdg-desktop-portal-wlr # xdg-desktop-portal backend for wlroots
AddPackage xdg-user-dirs # Manage user directories like ~/Desktop and ~/Music
AddPackage xorg-xev # Print contents of X events
AddPackage xorg-xinput # Small commandline tool to configure devices
AddPackage xorg-xrandr # Primitive command line interface to RandR extension
AddPackage xorg-xwayland # run X clients under wayland
AddPackage handlr-regex # Powerful alternative to xdg-utils (maintained fork of handlr)
AddPackage ttf-nerd-fonts-symbols # Nerd Font icons only, as a fallback for any font (replaces the removed nerd-fonts-complete)
AddPackage --foreign sworkstyle # Swayest Workstyle - This tool will rename workspaces to the icons configured. Mainly meant for Sway WM
CopyFile /etc/pulse/default.pa
CreateLink /etc/systemd/system/bluetooth.target.wants/bluetooth.service /usr/lib/systemd/system/bluetooth.service
CreateLink /etc/systemd/system/dbus-org.bluez.service /usr/lib/systemd/system/bluetooth.service
CreateLink /etc/systemd/user/graphical-session-pre.target.wants/xdg-user-dirs.service /usr/lib/systemd/user/xdg-user-dirs.service
CreateLink /etc/systemd/user/pipewire-session-manager.service /usr/lib/systemd/user/wireplumber.service
CreateLink /etc/systemd/user/pipewire.service.wants/wireplumber.service /usr/lib/systemd/user/wireplumber.service
CreateLink /etc/systemd/user/sockets.target.wants/gcr-ssh-agent.socket /usr/lib/systemd/user/gcr-ssh-agent.socket
CreateLink /etc/systemd/user/sockets.target.wants/gnome-keyring-daemon.socket /usr/lib/systemd/user/gnome-keyring-daemon.socket
CreateLink /etc/systemd/user/sockets.target.wants/p11-kit-server.socket /usr/lib/systemd/user/p11-kit-server.socket
CreateLink /etc/systemd/user/sockets.target.wants/pipewire.socket /usr/lib/systemd/user/pipewire.socket
CreateLink /etc/systemd/user/sockets.target.wants/pulseaudio.socket /usr/lib/systemd/user/pulseaudio.socket
CopyFile /etc/xdg/waybar/style.css
AddPackage swaybg # Wallpaper tool for Wayland compositors
AddPackage qt6-wayland # Provides APIs for Wayland
AddPackage otf-font-awesome # Iconic font designed for Bootstrap - otf format
AddPackage gvfs # Virtual filesystem implementation for GIO
