python3 - <<'PY'
import tomllib
s = open("config.toml").read()
d = tomllib.loads(s)
assert d["server"]["port"] == 8080 and d["server"]["host"] == "127.0.0.1"
assert d["ui"]["scrollback"] == 5000 and d["ui"]["theme"] == "dark"
assert d["ui"]["keys"] == {"quit": "q", "search": "/"}
for c in ("# herdr config", "# listen address", 'theme = "dark"   # keep this comment'):
    assert c in s, c
assert s.count("[ui.keys]") == 1
PY
