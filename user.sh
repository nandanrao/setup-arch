# LANGUAGE SETUP
nvm install v12
go get golang.org/x/tools/gopls

pip install --user \
    ipython

# systemctl
systemctl --user enable dropbox
systemctl --user enable borg.timer

# Misc
go get -u github.com/odeke-em/drive/cmd/drive
GO111MODULE="on" go get sigs.k8s.io/kind@v0.8.1

npm install -g @marp-team/marp-cli
npm install -g typescript
npm install -g typescript-language-server

# Emacs LSP servers (eglot)
# uv handles isolated Python tool installs cleanly (no global pip pollution)
sudo pacman -S --needed --noconfirm uv
# Python: basedpyright (types) + ruff (lint/format)
uv tool install basedpyright
uv tool install ruff
# Rust: rust-analyzer (also available via `rustup component add rust-analyzer`)
sudo pacman -S --needed --noconfirm rust-analyzer
# Go: gopls (eglot picks this up automatically)
go install golang.org/x/tools/gopls@latest

# Kube no trouble
sh -c "$(curl -sSL https://git.io/install-kubent)"
