cat > confparse.py <<'PY'
def tokenize(text):
    toks, i, line, n = [], 0, 1, len(text)
    while i < n:
        c = text[i]
        if c == "\n":
            line += 1; i += 1
        elif c.isspace():
            i += 1
        elif c == "#":
            while i < n and text[i] != "\n": i += 1
        elif c in ";{}":
            toks.append((c, None, line)); i += 1
        elif c in "\"'":
            q, start, buf = c, line, []
            i += 1
            while True:
                if i >= n: raise ValueError(f"unterminated quote at line {start}")
                ch = text[i]
                if ch == "\\" and i + 1 < n:
                    buf.append(text[i + 1]); line += text[i + 1] == "\n"; i += 2
                elif ch == q:
                    i += 1; break
                else:
                    line += ch == "\n"; buf.append(ch); i += 1
            toks.append(("word", "".join(buf), start))
        else:
            j = i
            while j < n and not text[j].isspace() and text[j] not in ";{}\"'": j += 1
            toks.append(("word", text[i:j], line)); i = j
    return toks


def parse(text):
    toks = tokenize(text)
    pos = 0

    def block(depth, open_line):
        nonlocal pos
        out = []
        while True:
            if pos >= len(toks):
                if depth: raise ValueError(f"unclosed block opened at line {open_line}")
                return out
            kind, val, line = toks[pos]
            if kind == "}":
                if not depth: raise ValueError(f"unexpected '}}' at line {line}")
                pos += 1
                return out
            if kind != "word": raise ValueError(f"unexpected '{kind}' at line {line}")
            name = val; pos += 1; args = []
            while True:
                if pos >= len(toks): raise ValueError(f"missing ';' at line {toks[-1][2]}")
                k, v, l = toks[pos]
                if k == "word": args.append(v); pos += 1
                elif k == ";": pos += 1; out.append({"name": name, "args": args}); break
                elif k == "{":
                    pos += 1; out.append({"name": name, "args": args, "block": block(depth + 1, l)}); break
                else: raise ValueError(f"unexpected '}}' at line {l}")
    return block(0, 0)
PY
