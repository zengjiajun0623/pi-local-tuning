python3 - <<'PY'
import configparser, re
def load(p):
    c = configparser.ConfigParser(strict=False, interpolation=None, delimiters=("=",))
    c.optionxform = str
    c.read(p)
    return c
s = load("sync.service")
assert s["Service"]["ExecStart"].strip() == "/usr/bin/rclone sync /home/me/docs remote:docs"
assert s["Service"]["Restart"].strip() in ("on-failure", "always")
assert re.fullmatch(r"30s?|30sec|30 ?seconds?", s["Service"]["RestartSec"].strip())
assert s["Service"].get("Type", "simple").strip() in ("simple", "oneshot", "exec")
if s["Service"].get("Type", "").strip() == "oneshot":
    pass
t = load("sync.timer")
T = t["Timer"]
ok15 = re.fullmatch(r"15 ?(min|m|minutes?)|900s?", T.get("OnUnitActiveSec", "").strip() or T.get("OnUnitInactiveSec", "").strip() or "x") \
    or re.fullmatch(r"\*:0?0/15(:00)?|\*-\*-\* \*:0?0/15(:00)?|\*:00,15,30,45|\*:0/15", T.get("OnCalendar", "").strip())
assert ok15, dict(T)
assert "OnBootSec" in T or "OnStartupSec" in T or T.get("Persistent", "").strip() == "true"
assert t["Install"]["WantedBy"].strip() == "timers.target"
assert t["Timer"].get("Unit", "sync.service").strip() == "sync.service"
PY
