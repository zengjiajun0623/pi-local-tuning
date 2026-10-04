set -e
orig='import re
import unicodedata


def slugify(s, max_len=50):
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()
    return s[:max_len].rstrip("-")'
[ "$(cat slugify.py)" = "$orig" ]
python3 test_slugify.py >/dev/null
killed=0
for m in 's/).lower()/)/' 's/.strip("-")//' 's/\[:max_len\].rstrip("-")/[:max_len]/' 's/normalize("NFKD", s)/normalize("NFC", s)/' 's/\[^a-zA-Z0-9\]+/[^a-zA-Z0-9]/'; do
  t=$(mktemp -d); cp test_slugify.py "$t/"; echo "$orig" | sed "$m" > "$t/slugify.py"
  if ! (cd "$t" && timeout 20 python3 test_slugify.py >/dev/null 2>&1); then killed=$((killed+1)); fi
  rm -rf "$t"
done
echo "mutants killed: $killed/5"
[ $killed -eq 5 ]
