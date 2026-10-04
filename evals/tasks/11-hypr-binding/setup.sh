cat > bindings.conf <<'H'
# Application bindings
bind = SUPER, RETURN, exec, $terminal
bind = SUPER, B, exec, $browser
bind = SUPER SHIFT, F, exec, $fileManager

# Window management
bind = SUPER, W, killactive,
bind = SUPER, F, fullscreen, 0
bind = SUPER SHIFT, N, workspace, empty
H
