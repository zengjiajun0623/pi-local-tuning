got=$(sed 's/[[:space:]]*$//' answer.txt | grep -v '^$')
# "sorted alphabetically": accept byte order or case-insensitive order
[ "$got" = "$(printf 'Epsilon\ngamma\ntheta\nzeta')" ] || [ "$got" = "$(printf 'Epsilon\ngamma\ntheta\nzeta' | sort -f)" ]
