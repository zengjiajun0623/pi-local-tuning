set -e
grep -q 'set -euo pipefail' run.sh
rm -rf items
[ "$(env -u GREETING ./run.sh)" = "Hello, world: 0 items" ]
mkdir items
[ "$(env -u GREETING ./run.sh)" = "Hello, world: 0 items" ]
touch items/a items/b "items/c d"
[ "$(env -u GREETING ./run.sh Bob)" = "Hello, Bob: 3 items" ]
[ "$(GREETING=Hi ./run.sh Bob)" = "Hi, Bob: 3 items" ]
rm -rf items
