#!/usr/bin/env bash
# Dropbox selective sync: which folders this laptop does NOT download.
# The list lives in dropbox-exclude.txt, one folder per line, relative to ~/Dropbox.
#
#     ./dropbox-excludes.sh save     # write this laptop's current excludes to the file
#     ./dropbox-excludes.sh apply    # exclude every folder in the file (new laptop)
#
# Dropbox keeps selective sync per device, inside ~/.dropbox, which isn't backed up.
# So a new laptop starts out downloading everything; `apply` stops that.
set -euo pipefail

LIST=$(cd "$(dirname "$0")" && pwd)/dropbox-exclude.txt
cd ~/Dropbox

case ${1:-} in
save)
	# First line of the output is the "Excluded:" header.
	dropbox-cli exclude list | tail -n +2 | sort >"$LIST"
	echo "Saved $(wc -l <"$LIST") folders to $LIST. Commit it if it changed."
	;;
apply)
	# A folder can only be excluded once Dropbox has created it here. It creates the
	# folder tree before downloading files, so allow up to 5 minutes in total.
	deadline=$((SECONDS + 300))
	missing=()
	while IFS= read -r dir; do
		[[ -n $dir ]] || continue
		while [[ ! -d $dir ]] && ((SECONDS < deadline)); do sleep 5; done
		if [[ -d $dir ]]; then
			dropbox-cli exclude add "$dir" >/dev/null
			echo "excluded  $dir"
		else
			missing+=("$dir")
		fi
	done <"$LIST"
	if ((${#missing[@]})); then
		echo
		echo "Never appeared (deleted or renamed in Dropbox?):"
		printf '  %s\n' "${missing[@]}"
	fi
	;;
*)
	echo "usage: $0 save|apply"
	exit 1
	;;
esac
