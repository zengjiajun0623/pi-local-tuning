cat > config.toml <<'T'
# herdr config
[server]
# listen address
host = "127.0.0.1"
port = 7070

[ui]
theme = "dark"   # keep this comment
scrollback = 1000

[ui.keys]
quit = "q"
T
