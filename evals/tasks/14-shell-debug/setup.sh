cat > run.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
NAME=$1
GREETING=$GREETING
count=$(ls items | wc -l)
echo "$GREETING, $NAME: $count items"
SH
chmod +x run.sh
