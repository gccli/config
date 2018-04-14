#! /bin/bash

myself=$(readlink -f $0)
cat > /tmp/crontab <<EOF
01  04   *    *    *   $myself
01  08   *    *    *   $myself
01  12   *    *    *   $myself
01  16   *    *    *   $myself
01  20   *    *    *   $myself
01  22   *    *    *   $myself
EOF
chmod 666 /tmp/crontab


function log() {
    logger -p local0.warn -t "[$0]" -s "$*" 2>&1 | tee -a ~/.git.log
}

function gitupdate() {
    repo=$1
    cd $repo
    log "check $repo/.git"
    if [ ! -d .git ]; then
        log "No such directory $repo/.git"
    fi
    log "update $(pwd)"
    log "$(git pull 2>&1)"
}

log "========[$(date +'%F %T')]========"
for line in $(sort -u ~/.gitrepos)
do
    dir=$(echo -n $line | awk '{$1=$1;print}')
    [ -z "$dir" ] && continue
    (gitupdate $dir)
done
