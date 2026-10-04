python3 - <<'PY'
s=open("dupes.py").read()
s=s.replace('''    out = []
    for i, x in enumerate(xs):
        if x in xs[:i] and x not in out:
            out.append(x)
    return out''','''    seen, done, out = set(), set(), []
    for x in xs:
        if x in seen and x not in done:
            out.append(x)
            done.add(x)
        seen.add(x)
    return out''')
open("dupes.py","w").write(s)
PY
