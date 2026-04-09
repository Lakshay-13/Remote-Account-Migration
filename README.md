# Remote Account Migration

A robust bash utility designed to simplify the backup and restoration of Linux user accounts. This tool is particularly useful for migrating environments between servers or creating snapshots of a user's configuration and home directory.

## Features

- **Home Directory Backup**: Selective synchronization of your home directory using `rsync`.
- **Intelligent Exclusions**: Automatically excludes the backup directory itself to prevent infinite nesting.
- **Environment Capture**:
  - Exports Conda environment definitions (`conda_env.yml`).
  - Freezes Python pip requirements (`requirements.txt`).
  - Backs up SSH keys and configurations.
  - Captures user crontabs.
  - Exports installed system packages (via `dpkg`).
  - Dumps PostgreSQL databases (via `pg_dumpall`).
- **Compression**: Packages everything into a single `.tar.gz` archive for easy transfer.
- **Seamless Restore**: Automatically handles archive extraction and restores configurations with appropriate permissions.

## Installation

```bash
git clone https://github.com/Lakshay-13/Remote-Account-Migration.git
cd Remote-Account-Migration
chmod +x migrate_account_v2.sh
```

## Usage

### Backup

By default, the script creates a backup in `~/account_backup` and then archives it to `~/account_backup.tar.gz`.

```bash
./migrate_account_v2.sh backup [optional_backup_path]
```

### Restore

You can restore from a directory or directly from a `.tar.gz` archive.

```bash
# From an archive
./migrate_account_v2.sh restore ~/account_backup.tar.gz

# From a directory
./migrate_account_v2.sh restore ~/account_backup
```

## Backup Structure

The backup directory (and resulting archive) contains:
- `home/`: The synchronized contents of your `$HOME`.
- `.ssh/`: Your SSH configuration and keys.
- `conda_env.yml`: Conda environment export.
- `requirements.txt`: Python pip freeze.
- `cron.txt`: User crontab.
- `packages.txt`: List of installed system packages.
- `postgres.sql`: PostgreSQL database dump.

## Notes

- **Permissions**: The script attempts to restore SSH key permissions (`700` for `.ssh`, `600` for keys).
- **Package Restoration**: On restoration, the script will attempt to use `apt-get` to install missing packages listed in `packages.txt`. This requires `sudo` privileges.
- **Database Restoration**: PostgreSQL restoration requires `psql` to be installed and available.
