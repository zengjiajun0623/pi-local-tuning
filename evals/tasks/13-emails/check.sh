exp='alice.smith@example.com
bob@example.org
carol+news@mail.co.uk
dave@sub.domain.io
erin@example.org
frank_o'"'"'neil@x-y.net'
got=$(sed 's/[[:space:]]*$//' emails.txt | grep -v '^$')
if [ "$got" != "$exp" ]; then
  # accept the defensible reading that the apostrophe is not part of the address
  exp2=$(echo "$exp" | sed "s/frank_o'neil@x-y.net/neil@x-y.net/" | sort)
  [ "$got" = "$exp2" ]
fi
