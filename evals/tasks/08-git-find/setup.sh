git init -q . && git config user.email t@t && git config user.name t
for i in 1 2 3 4 5 6 7 8; do
  echo "line $i" >> notes.txt
  [ $i = 3 ] && echo "# FIXME-41 old" >> lib.py
  [ $i = 5 ] && echo "# FIXME-42 handle unicode" >> lib.py
  [ $i = 7 ] && sed -i 's/FIXME-42 handle unicode/FIXME-42 handle unicode properly/' lib.py
  touch lib.py; git add -A && git commit -qm "change $i" --date="2026-01-0$i 10:00"
done
