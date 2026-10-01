# Languages, toolchains, editors and dev utilities

AddPackage autoconf  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage automake  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage bcprov # Bouncy Castle Crypto APIs for Java
AddPackage binutils  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage bison  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage dart-sass # Sass makes CSS fun again
AddPackage fakeroot  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage flatbuffers # An efficient cross platform serialization library for C++, with support for Java, C# and Go
AddPackage flex  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage gcc  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage gcc-fortran # Fortran front-end for GCC
AddPackage gdal # A translator library for raster and vector geospatial data formats
AddPackage geckodriver # Proxy for using W3C WebDriver-compatible clients to interact with Gecko-based browsers.
AddPackage gist # Potentially the best command line gister
AddPackage git # the fast distributed version control system
AddPackage github-cli # The GitHub CLI
AddPackage gitleaks # Audit Git repos for secrets and keys
AddPackage go # Core compiler tools for the Go programming language
AddPackage groff  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage hugo # Fast and Flexible Static Site Generator in Go
AddPackage java-commons-lang # A host of helper utilities for the java.lang API
AddPackage leiningen # Automate Clojure projects
AddPackage libgit2 # A linkable library for Git
AddPackage librdkafka # The Apache Kafka C/C++ library
AddPackage libtool  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage luajit # Just-in-time compiler and drop-in replacement for Lua 5.1
AddPackage m4  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage make  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage mkcert # Simple tool for making locally-trusted development certificates
AddPackage nvm # Node Version Manager - Simple bash script to manage multiple active node.js versions
AddPackage patch  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage pkgconf  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage poppler-glib # Poppler glib bindings
AddPackage pyenv # Easily switch between multiple versions of Python
AddPackage python # The Python programming language
AddPackage python-gdal # Python bindings for GDAL
AddPackage python-pdm # A modern Python package and dependency manager supporting the latest PEP standards
AddPackage python-pip # The PyPA recommended tool for installing Python packages
AddPackage python-pipx # Install and Run Python Applications in Isolated Environments
AddPackage python-poetry # Python dependency management and packaging made easy
AddPackage python-virtualenv # Virtual Python Environment builder
AddPackage r # Language and environment for statistical computing and graphics
AddPackage rbenv # Manage your app's Ruby environment
AddPackage ruby-build # A tool to download, compile, and install Ruby on Unix-like systems
AddPackage rust-analyzer # Rust compiler front-end for IDEs
AddPackage texinfo  # REVIEW: part of base-devel; listing it separately is redundant
AddPackage tk # A windowing toolkit for use with tcl
AddPackage uv # An extremely fast Python package installer and resolver written in Rust
AddPackage --foreign bfg # Removes large or troublesome blobs like git-filter-branch does, but faster.
AddPackage --foreign cursor-bin # AI-first coding environment
AddPackage --foreign ngrok # A tunneling, reverse proxy for developing and understanding networked, HTTP services
AddPackage --foreign pandoc-bin  # static binary: needs no Haskell packages (Arch's plain pandoc pulls in ~150)
AddPackage --foreign postman-bin # Build, test, and document your APIs faster
AddPackage --foreign pyenv-virtualenv # pyenv plugin to manage virtualenv (a.k.a. python-virtualenv)
AddPackage --foreign visual-studio-code-bin # Visual Studio Code (vscode): Editor for building and debugging modern web and cloud applications (official binary version)
CopyFile /etc/ca-certificates/trust-source/anchors/mkcert_development_CA_285199253346378376943519832407666220589.crt
CopyFile /etc/makepkg.conf.d/fortran.conf
CopyFile /etc/makepkg.conf.d/rust.conf
AddPackage cmake # A cross-platform open-source make system
AddPackage python-setuptools # Easily download, build, install, upgrade, and uninstall Python packages
AddPackage --foreign openssl-1.1 # Legacy OpenSSL; needed by pyenv Pythons 3.9.13 and 2.7.18 (ssl/hashlib modules)
