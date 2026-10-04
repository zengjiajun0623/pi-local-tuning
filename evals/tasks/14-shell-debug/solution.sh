cat > run.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
NAME=${1:-world}
GREETING=${GREETING:-Hello}
count=0
[ -d items ] && count=$(find items -mindepth 1 -maxdepth 1 | wc -l)
echo "$GREETING, $NAME: $count items"
SH
