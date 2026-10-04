python3 - <<'PY'
import random
r = random.Random(13)
ips = [f"10.0.{a}.{b}" for a in range(3) for b in range(1, 9)] + ["192.168.1.50", "172.16.4.4", "10.0.1.5"]
weights = [r.randint(1, 20) for _ in ips]
paths = ["/", "/api/items", "/login", "/static/app.js", "/api/items/5?x=500", "/health"]
codes = [200]*30 + [301, 304, 404, 404, 403, 500, 502, 503, 504]
with open("access.log", "w") as f:
    for i in range(3000):
        ip = r.choices(ips, weights)[0]
        code = r.choice(codes)
        size = r.randint(100, 9000)
        ua = r.choice(['"Mozilla/5.0 (X11; Linux x86_64)"', '"curl/8.5.0"', '"Mozilla/5.0 (status 500 test)"'])
        f.write(f'{ip} - - [04/Oct/2026:10:{i//60%60:02d}:{i%60:02d} +0000] "GET {r.choice(paths)} HTTP/1.1" {code} {size} "-" {ua}\n')
PY
