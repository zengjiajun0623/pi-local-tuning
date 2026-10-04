cat > backup.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
mkdir -p backups
tar -czf "backups/data-$(date +%Y%m%d-%H%M%S).tar.gz" data
ls -1 backups/data-*.tar.gz | sort -r | tail -n +4 | xargs -r rm --
SH
chmod +x backup.sh
