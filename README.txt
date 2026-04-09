UPDATED MIGRATION SCRIPT (WITH TAR SUPPORT)

Default backup path:
~/account_backup

Backup creates:
~/account_backup.tar.gz

USAGE

chmod +x migrate_account_v2.sh

Backup:
./migrate_account_v2.sh backup

Restore:
./migrate_account_v2.sh restore ~/account_backup.tar.gz

Notes:
- Archive auto-extracts on restore
- Folder name expected: account_backup
- Not a perfect system clone (obviously)
