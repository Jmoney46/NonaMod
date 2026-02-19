#!/usr/bin/env python3
import os
BACKUP_DIR="/mnt/stateful_partition/murkmod/backups"
for f in sorted(os.listdir(BACKUP_DIR)):
    if f.startswith("mushm_backup") and f.endswith(".tar.gz"):
        print(f)
