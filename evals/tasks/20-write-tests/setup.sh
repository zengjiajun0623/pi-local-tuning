cat > slugify.py <<'PY'
import re
import unicodedata


def slugify(s, max_len=50):
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()
    return s[:max_len].rstrip("-")
PY
