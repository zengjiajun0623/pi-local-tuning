grep -rlw get_usr --include='*.py' . | xargs sed -i 's/\bget_usr\b/get_user/g'
