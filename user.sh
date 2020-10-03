# YAY
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ../
rm -rf yay

yay -s \
    dropbox \
    dropbox-cli \
    nvm \
    google-cloud-sdk \
    ngrok \
    snapd \
    google-chrome \
    visual-studio-code-bin \
    zoom \
    tor-browser

# microk8s
sudo snap install microk8s --classic --edge
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
su - $USER

# GROUPS
sudo usermod -aG docker $USER
sudo usermod -aG video $USER
sudo usermod -aG microk8s $USER

# LANGUAGE SETUP
nvm install v12
go get golang.org/x/tools/gopls

pip install --user \
    ipython \
    osgeo


# flatpaks
flatpak install flathub com.skype.Client
flatpak install flathub com.slack.Slack
flatpak install flathub com.elsevier.MendeleyDesktop

# systemctl
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now docker
sudo systemctl enable --now bluetooth
sudo systemctl enable --now snapd.socket
systemctl --user enable dropbox
systemctl --user enable borg.timer

# Misc
go get -u github.com/odeke-em/drive/cmd/drive
GO111MODULE="on" go get sigs.k8s.io/kind@v0.8.1

sudo ln -s /var/lib/snapd/snap /snap


# UPF VPN
# create if not exists
# sudo echo "alias char-major-108 ppp_generic" >> /etc/modprobe.d/modules.conf
