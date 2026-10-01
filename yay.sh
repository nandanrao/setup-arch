# paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ../
rm -rf paru

paru -Syu \
    pandoc-bin \
    dropbox \
    dropbox-cli \
    nvm \
    google-cloud-sdk \
    ngrok \
    snapd \
    google-chrome \
    visual-studio-code-bin \
    zoom \
    tor-browser \
    slack-desktop \
    mendeleydesktop-bundled \
    skypeforlinux-stable-bin \
    handlr-bin \
    spotify \
    jazz-midi-plugin-bin \
    dart-sass \
    leiningen \
    aws-cli \
    python-poetry \
    eksctl \
    tex2png \
    nerd-fonts-complete \
    kubectx




# For v8-r:
# https://github.com/JanMarvin/archpkgs
# and then:
# sudo pacman -Syu v8-r
