sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -Syu \
    dropbox \
    dropbox-cli \
    google-cloud-sdk \
    google-cloud-sdk-gke-gcloud-auth-plugin \
    google-cloud-cli \
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
    ruby-build \
    rbenv \
    kubectx \
    eksctl \
    pandoc-bin \
    nm-connection-editor \
    network-manager-applet \
    hfsprogs \
    postman-bin \
    python-pipx \
    pyenv \
    python-poetry-git \
    go-mtpfs-git \
    nerd-fonts-complete \ 
    emacs-lsp-booster \
    hugo \ 
    tex2png \ 
    uv \
    netlify-cli

BUILDDIR=/tmp/makepkg paru -S --mflags --nocheck v8
