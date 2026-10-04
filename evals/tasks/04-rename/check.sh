set -e
if grep -rnw 'get_usr' --include='*.py' .; then exit 1; fi
grep -q 'def get_usr_count' app/users.py
grep -q 'def get_user(' app/users.py
python3 run_tests.py
python3 -c 'from app.users import get_user; assert get_user(1)=="ada"'
