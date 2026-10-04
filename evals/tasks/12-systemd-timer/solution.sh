printf '[Unit]\nDescription=sync\n\n[Service]\nExecStart=/usr/bin/rclone sync /home/me/docs remote:docs\nRestart=on-failure\nRestartSec=30\n' > sync.service
printf '[Unit]\nDescription=sync timer\n\n[Timer]\nOnBootSec=2min\nOnUnitActiveSec=15min\n\n[Install]\nWantedBy=timers.target\n' > sync.timer
