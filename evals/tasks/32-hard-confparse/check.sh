python3 - <<'PY'
from confparse import parse
src = '''# top comment
worker_processes 4;   # trailing
events {}
http {
    server {
        listen 80 default_server;
        server_name "example.com" 'www.example.com';
        location / { root /var/www;}
        add_header X-Note "a;b {c} # not comment";
        return 200 "say \\"hi\\" \\\\ ok";
        color a#b;
        empty "";
    }
}
'''
D = lambda n, a=(), b=None: ({"name": n, "args": list(a)} if b is None else {"name": n, "args": list(a), "block": b})
exp = [D("worker_processes", ["4"]), D("events", [], []),
       D("http", [], [D("server", [], [
           D("listen", ["80", "default_server"]), D("server_name", ["example.com", "www.example.com"]),
           D("location", ["/"], [D("root", ["/var/www"])]),
           D("add_header", ["X-Note", "a;b {c} # not comment"]),
           D("return", ["200", 'say "hi" \\ ok']), D("color", ["a#b"]), D("empty", [""])])])]
got = parse(src)
assert got == exp, got
assert parse("") == [] and parse("# only\n\n") == []
assert parse("a{b{c;}}") == [D("a", [], [D("b", [], [D("c")])])]
def err(text, line):
    try:
        parse(text)
    except ValueError as e:
        assert f"line {line}" in str(e), (text, str(e)); return
    raise SystemExit(f"no ValueError for {text!r}")
err("a;\n}\n", 2)
err("a 1;\nb 2", 2)
err("x;\nhttp {\n  a;\n", 2)
err("a;\nb \"unterminated;\nc;\n", 2)
err("a;\n\n;\n", 3)
err("{ a; }", 1)
print("ok")
PY
