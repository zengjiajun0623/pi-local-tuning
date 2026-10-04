set -e
[ -x backup.sh ]
here=$(pwd)
rm -rf backups && mkdir backups
for d in 20200101-000000 20210101-000000 20220101-000000 20230101-000000; do
  echo old > "backups/data-$d.tar.gz"; touch -d "${d:0:8}" "backups/data-$d.tar.gz"
done
(cd / && "$here/backup.sh") >/dev/null
n=$(ls backups/data-*.tar.gz | wc -l); [ "$n" -eq 3 ]
[ -f backups/data-20230101-000000.tar.gz ] && [ -f backups/data-20220101-000000.tar.gz ]
new=$(ls backups/data-*.tar.gz | grep -v -E '2022|2023')
echo "$new" | grep -qE 'data-[0-9]{8}-[0-9]{6}\.tar\.gz$'
tar -tzf "$new" | grep -q 'data/a.txt'
tar -tzf "$new" | grep -q 'data/sub/b.txt'
