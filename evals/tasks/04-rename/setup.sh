mkdir -p app
cat > app/users.py <<'PY'
USERS = {1: "ada", 2: "linus"}


def get_usr(uid):
    return USERS.get(uid)


def get_usr_count():
    return len(USERS)
PY
cat > app/api.py <<'PY'
from app.users import get_usr, get_usr_count


def handle(uid):
    name = get_usr(uid)
    return {"name": name, "total": get_usr_count()}
PY
cat > app/cli.py <<'PY'
from app import users


def show(uid):
    return f"user={users.get_usr(uid)}"
PY
cat > app/__init__.py <<'PY'
PY
cat > run_tests.py <<'PY'
from app.api import handle
from app.cli import show
from app import users

assert handle(1) == {"name": "ada", "total": 2}
assert show(2) == "user=linus"
assert users.get_usr_count() == 2
print("ok")
PY
