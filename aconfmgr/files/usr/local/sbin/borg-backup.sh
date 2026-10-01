export BORG_REPO=ssh://faan3tku@faan3tku.repo.borgbase.com/./repo
# Runs as root from a system unit, which has no session D-Bus and no unlocked
# login keyring, so secret-tool is not usable here. Passphrase lives in a
# 0600 root:root file on the LUKS root filesystem instead.
export BORG_PASSCOMMAND='cat /root/.borg-passphrase'
export BORG_RSH="ssh -i /home/nandan/.ssh/borg_backup"
# Repo was relocated from ~/Dropbox/laptop/backup to BorgBase on 2026-07-22.
# This acknowledges the intended move so the unattended job doesn't stall on the prompt.
export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

borg create --verbose --list --filter AME --stats --show-rc --exclude-caches \
     --exclude '/home/*/.cache/*'    \
     --exclude '/home/nandan/Dropbox' \
     --exclude '/home/nandan/Drive' \
     --exclude '/home/nandan/Movies' \
     --exclude '/home/nandan/.dropbox' \
     --exclude '/home/nandan/.dropbox-dist' \
     --exclude '/home/nandan/.vscode-oss' \
     --exclude '/home/nandan/.vscode' \
     --exclude '/home/nandan/.npm' \
     --exclude '/home/nandan/.nvm' \
     --exclude '/home/*/node_modules/*' \
     --exclude '/home/*/venv/*' \
     --exclude '/home/*/.venv/*' \
     --exclude '*.pyc' \
     ::'{now}' \
     /home/nandan/ \
     /etc

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                          \
    --list                          \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6

prune_exit=$?

info "Compacting repository"

# `prune` only marks archives for deletion -- it does not free any space on the
# server. `compact` is what actually reclaims it, so without this the repo grows
# against the BorgBase quota forever. --threshold 10 (the default) means segments
# are only rewritten once at least 10% of a segment is reclaimable, which keeps
# the daily run cheap when there is little to reclaim.

borg compact --verbose                        \
    --show-rc                       \
    --threshold 10

compact_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune and/or Compact finished with warnings"
else
    info "Backup, Prune and/or Compact finished with errors"
fi

exit ${global_exit}
