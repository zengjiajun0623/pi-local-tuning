python3 - <<'PY'
import os, random
r = random.Random(5)
os.makedirs("app/plugins/compat", exist_ok=True); os.makedirs("config/tenants", exist_ok=True); os.makedirs("config/env", exist_ok=True)
w = lambda p, s: open(p, "w").write(s)
w("README.md", """# eventhub

Routing: each event is routed by config. Precedence: default < env < tenant
(tenant config overrides everything, so customers can pin their handlers).
Disabled handlers are skipped. See app/loader.py.
""")
w("app/__init__.py", "")
w("app/aliases.py", '''# Legacy event names -> canonical names
ALIASES = {
    "order.refunded": "order.refund",
    "order.paid": "payment.captured",
    "user.deleted": "account.closed",
}


def canonical(event):
    return ALIASES.get(event, event)
''')
w("app/registry.py", '''import httpx  # used by remote handlers

_REGISTRY = {}

FALLBACKS = {
    "order.refund": "refund-legacy",
    "payment.captured": "capture-basic",
}


def handler(name, priority=0):
    def deco(cls):
        cur = _REGISTRY.get(name)
        if cur is None or priority > cur[0]:
            _REGISTRY[name] = (priority, cls)
        return cls
    return deco


def lookup(name):
    return _REGISTRY[name][1]


def fallback_for(event):
    return FALLBACKS[event]
''')
w("app/loader.py", '''import tomllib
from . import registry
from .aliases import canonical
from . import plugins  # noqa: F401  (registers handlers)


def _load(path):
    try:
        with open(path, "rb") as f:
            return tomllib.load(f)
    except FileNotFoundError:
        return {}


def resolve(event, tenant, env):
    event = canonical(event)
    layers = [
        _load("config/default.toml"),
        _load(f"config/tenants/{tenant}.toml"),
        _load(f"config/env/{env}.toml"),
    ]
    name = None
    for layer in layers:  # later layers win
        name = layer.get("routes", {}).get(event, name)
    disabled = set(_load(f"config/env/{env}.toml").get("disabled", []))
    if name in disabled:
        name = registry.fallback_for(event)
    return registry.lookup(name)
''')
mods = []
words = ["invoice", "shipping", "stock", "email", "audit", "search", "tax", "loyalty", "fraud", "export", "webhook", "sms", "coupon", "review", "media"]
for i, wd in enumerate(words):
    mods.append(f"{wd}_handlers")
    body = "from ..registry import handler\n\n\n"
    for j in range(r.randint(3, 6)):
        cname = f"{wd.capitalize()}{['Sync','Async','Batch','Remote','Local','Fast'][j]}Handler"
        body += f'@handler("{wd}-{j}", priority={r.randint(0, 3)})\nclass {cname}:\n    def handle(self, event):\n        return "{wd}:{j}"\n\n\n'
    w(f"app/plugins/{wd}_handlers.py", body)
w("app/plugins/refund_handlers.py", '''from ..registry import handler


@handler("refund-basic")
class BasicRefundHandler:
    def handle(self, event):
        return "basic"


@handler("refund-acme", priority=1)
class AcmeRefundHandler:
    def handle(self, event):
        return "acme"


@handler("refund-v2", priority=2)
class RefundV2Handler:
    def handle(self, event):
        return "v2"


@handler("refund-legacy", priority=1)
class LegacyRefundHandler:
    def handle(self, event):
        return "legacy"
''')
w("app/plugins/compat/__init__.py", "")
w("app/plugins/compat/refund_legacy2.py", '''from ...registry import handler


@handler("refund-legacy", priority=5)
class LegacyRefundHandlerV2:
    """Drop-in replacement for the legacy refund flow."""
    def handle(self, event):
        return "legacy2"


@handler("refund-acme", priority=0)
class AcmeRefundHandlerOld:
    def handle(self, event):
        return "acme-old"
''')
w("app/plugins/compat/unused.py", '''from ...registry import handler


@handler("refund-legacy", priority=9)
class LegacyRefundHandlerV3:
    def handle(self, event):
        return "legacy3"
''')
imports = "\n".join(f"from . import {m}  # noqa: F401" for m in mods + ["refund_handlers"])
w("app/plugins/__init__.py", imports + "\nfrom .compat import refund_legacy2  # noqa: F401\n")
w("config/default.toml", '[routes]\n"order.refund" = "refund-basic"\n"payment.captured" = "capture-basic"\n"order.refunded" = "refund-v2"\n')
w("config/tenants/acme.toml", '[routes]\n"order.refund" = "refund-acme"\n')
w("config/tenants/globex.toml", '[routes]\n"order.refund" = "refund-v2"\n')
w("config/env/production.toml", 'disabled = ["refund-v2", "refund-acme"]\n\n[routes]\n"payment.captured" = "capture-fast"\n')
w("config/env/staging.toml", '[routes]\n"order.refund" = "refund-v2"\n')
PY
