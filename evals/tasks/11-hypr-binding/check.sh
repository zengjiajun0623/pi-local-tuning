python3 - <<'PY'
import re
lines = open("bindings.conf").read().splitlines()
norm = [re.sub(r"\s+", " ", l.strip()) for l in lines]
wm = norm.index("# Window management")
app, win = norm[:wm], norm[wm:]
mod = r"SUPER ?_?SHIFT"
assert any(re.fullmatch(rf"bind = {mod}, ?B, ?exec, ?\$browser", l) for l in app), "browser"
assert not any(re.fullmatch(r"bind = SUPER, ?B, .*", l) for l in norm), "old B"
assert any(re.fullmatch(rf"bind = {mod}, ?N, ?exec, ?obsidian", l) for l in app), "obsidian"
for keep in ("bind = SUPER, RETURN, exec, $terminal", "bind = SUPER SHIFT, F, exec, $fileManager",
             "bind = SUPER, W, killactive,", "bind = SUPER, F, fullscreen, 0", "bind = SUPER SHIFT, N, workspace, empty"):
    assert keep in norm, keep
assert len([l for l in norm if l.startswith("bind")]) == 7
PY
