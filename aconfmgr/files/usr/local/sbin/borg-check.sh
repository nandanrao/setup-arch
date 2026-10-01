#!/usr/bin/env bash
# Monthly borg repository + archive consistency check.
# Read-only: never pass --repair from here. If this reports problems, inspect
# the output by hand before repairing anything -- --repair can discard data.

export BORG_REPO=ssh://faan3tku@faan3tku.repo.borgbase.com/./repo
export BORG_PASSCOMMAND='cat /root/.borg-passphrase'
export BORG_RSH="ssh -i /home/nandan/.ssh/borg_backup"

info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Check interrupted >&2; exit 2' INT TERM

info "Starting repository check"

# Default check = repository structure + archive metadata consistency.
# Deliberately NOT --verify-data: that re-downloads every chunk (~63 GB from
# BorgBase) to re-checksum it, which is not worth the egress on this cadence.
# --lock-wait covers overlap with the nightly backup job.

borg check                          \
    --verbose                       \
    --show-rc                       \
    --lock-wait 3600

check_exit=$?

if [ ${check_exit} -eq 0 ]; then
    info "Repository check finished successfully"
elif [ ${check_exit} -eq 1 ]; then
    info "Repository check finished with warnings"
else
    info "Repository check finished with errors"
fi

exit ${check_exit}
