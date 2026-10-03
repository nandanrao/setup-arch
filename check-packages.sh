#!/usr/bin/env bash
# Check that every package in aconfmgr/ can still be installed from scratch.
#
# acm save only compares the config with what's installed on this laptop. A package
# that was renamed or deleted on the AUR stays installed here, so acm save never
# notices; only a fresh install does. This catches that.
#
#     ./check-packages.sh
#
# Checks every AddPackage line, including both sides of hardware conditions
# (e.g. intel-ucode and amd-ucode). Repo packages are looked up in the local pacman
# database, so run `sudo pacman -Syu` first; AUR packages are looked up online.
set -euo pipefail
cd "$(dirname "$0")/aconfmgr"

mapfile -t repo < <(grep -hE '^\s*AddPackage ' ./*.sh | grep -v -- '--foreign' | awk '{print $2}' | sort -u)
mapfile -t aur < <(grep -hE '^\s*AddPackage --foreign ' ./*.sh | awk '{print $3}' | sort -u)

missing=()

# Repo packages: pacman -Si prints one "was not found" error per missing name.
while read -r name; do
	missing+=("$name (repos)")
done < <(pacman -Si -- "${repo[@]}" 2>&1 >/dev/null | sed -n "s/^error: package '\(.*\)' was not found$/\1/p")

# AUR packages: one batch lookup; any name not in the answer is gone.
query=$(printf '&arg[]=%s' "${aur[@]}")
found=$(curl -fsS "https://aur.archlinux.org/rpc/v5/info?${query#&}" |
	python3 -c 'import json, sys; print("\n".join(r["Name"] for r in json.load(sys.stdin)["results"]))')
for name in "${aur[@]}"; do
	grep -qxF "$name" <<<"$found" || missing+=("$name (AUR)")
done

if ((${#missing[@]})); then
	echo "Can't be installed any more (renamed, removed, or moved between AUR and repos):"
	printf '  %s\n' "${missing[@]}"
	echo "Look each one up on archlinux.org/packages and aur.archlinux.org, fix aconfmgr/, commit."
	exit 1
fi
echo "All ${#repo[@]} repo and ${#aur[@]} AUR packages can be installed."
