cat > dupes.py <<'PY'
import sys


def find_dupes(xs):
    out = []
    for i, x in enumerate(xs):
        if x in xs[:i] and x not in out:
            out.append(x)
    return out


if __name__ == "__main__":
    xs = [line.rstrip("\n") for line in open(sys.argv[1])]
    for d in find_dupes(xs):
        print(d)
PY
