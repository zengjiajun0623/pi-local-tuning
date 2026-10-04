cat > calc.py <<'PY'
import re

TOK = re.compile(r"\s*(?:(\d+\.\d*|\d*\.\d+|\d+)|([A-Za-z_]\w*)|(\*\*|[-+*/%(),]))")


def tokenize(s):
    pos, out = 0, []
    s = s.rstrip()
    while pos < len(s):
        m = TOK.match(s, pos)
        if not m or m.end() == pos:
            raise ValueError(f"bad token at {pos}")
        num, name, op = m.groups()
        if num is not None:
            nxt = s[m.end():m.end() + 1]
            if nxt == "." or (nxt and nxt.isalnum()):
                raise ValueError("bad number")
            out.append(("num", float(num)))
        elif name is not None:
            out.append(("name", name))
        else:
            out.append(("op", op))
        pos = m.end()
    return out


class P:
    def __init__(self, toks, vars):
        self.t, self.i, self.v = toks, 0, vars or {}

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else (None, None)

    def take(self, op=None):
        k, v = self.peek()
        if k is None or (op is not None and v != op):
            raise ValueError("unexpected token")
        self.i += 1
        return k, v

    def expr(self):
        x = self.term()
        while self.peek()[1] in ("+", "-") and self.peek()[0] == "op":
            op = self.take()[1]
            y = self.term()
            x = x + y if op == "+" else x - y
        return x

    def term(self):
        x = self.unary()
        while self.peek()[0] == "op" and self.peek()[1] in ("*", "/", "%"):
            op = self.take()[1]
            y = self.unary()
            if op == "*": x *= y
            else:
                if y == 0: raise ValueError("division by zero")
                x = x / y if op == "/" else x % y
        return x

    def unary(self):
        if self.peek()[0] == "op" and self.peek()[1] in ("+", "-"):
            op = self.take()[1]
            x = self.unary()
            return -x if op == "-" else x
        return self.power()

    def power(self):
        x = self.atom()
        if self.peek()[0] == "op" and self.peek()[1] == "**":
            self.take()
            return x ** self.unary()
        return x

    def atom(self):
        k, v = self.take()
        if k == "num": return v
        if k == "name":
            if self.peek()[1] == "(" and self.peek()[0] == "op":
                self.take("(")
                args = [self.expr()]
                while self.peek()[1] == ",":
                    self.take(","); args.append(self.expr())
                self.take(")")
                if v in ("min", "max"): return (min if v == "min" else max)(args)
                if v == "abs":
                    if len(args) != 1: raise ValueError("abs takes one argument")
                    return abs(args[0])
                raise ValueError("unknown function")
            if v not in self.v: raise ValueError("unknown variable")
            return self.v[v]
        if v == "(":
            x = self.expr(); self.take(")"); return x
        raise ValueError("unexpected token")


def evaluate(expr, variables=None):
    p = P(tokenize(expr), variables)
    x = p.expr()
    if p.i != len(p.t): raise ValueError("trailing input")
    return x
PY
