#!/usr/bin/env bash
set -e

MODE=$1
BACKUP_DIR=${2:-"$HOME/account_backup"}

echo "Mode: $MODE"
echo "Backup dir: $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"

HOME_DIR="$HOME"

if [[ "$MODE" == "backup" ]]; then
    rsync -a --exclude="$BACKUP_DIR" "$HOME_DIR/" "$BACKUP_DIR/home/"

    if command -v conda &> /dev/null; then
        conda env export > "$BACKUP_DIR/conda_env.yml" || true
    fi
    pip freeze > "$BACKUP_DIR/requirements.txt" || true

    cp -r "$HOME_DIR/.ssh" "$BACKUP_DIR/" 2>/dev/null || true
    crontab -l > "$BACKUP_DIR/cron.txt" 2>/dev/null || true

    if command -v dpkg &> /dev/null; then
        dpkg --get-selections > "$BACKUP_DIR/packages.txt"
    fi

    if command -v pg_dumpall &> /dev/null; then
        pg_dumpall > "$BACKUP_DIR/postgres.sql" || true
    fi

    echo "[*] Creating archive..."
    tar -czvf "${BACKUP_DIR}.tar.gz" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

    echo "[✓] Backup complete: ${BACKUP_DIR}.tar.gz"
    exit 0
fi

if [[ "$MODE" == "restore" ]]; then
    if [[ "$BACKUP_DIR" == *.tar.gz ]]; then
        echo "[*] Extracting archive..."
        tar -xzvf "$BACKUP_DIR" -C "$HOME"
        BACKUP_DIR="$HOME/account_backup"
    fi

    rsync -a "$BACKUP_DIR/home/" "$HOME_DIR/"

    if [[ -d "$BACKUP_DIR/.ssh" ]]; then
        cp -r "$BACKUP_DIR/.ssh" "$HOME_DIR/"
        chmod 700 "$HOME_DIR/.ssh"
        chmod 600 "$HOME_DIR/.ssh/"*
    fi

    if [[ -f "$BACKUP_DIR/conda_env.yml" ]] && command -v conda &> /dev/null; then
        conda env create -f "$BACKUP_DIR/conda_env.yml" || true
    elif [[ -f "$BACKUP_DIR/requirements.txt" ]]; then
        pip install -r "$BACKUP_DIR/requirements.txt" || true
    fi

    if [[ -f "$BACKUP_DIR/cron.txt" ]]; then
        crontab "$BACKUP_DIR/cron.txt"
    fi

    if [[ -f "$BACKUP_DIR/packages.txt" ]] && command -v dpkg &> /dev/null; then
        sudo dpkg --set-selections < "$BACKUP_DIR/packages.txt"
        sudo apt-get dselect-upgrade -y || true
    fi

    if [[ -f "$BACKUP_DIR/postgres.sql" ]] && command -v psql &> /dev/null; then
        psql -f "$BACKUP_DIR/postgres.sql" || true
    fi

    echo "[✓] Restore complete."
    exit 0
fi

echo "Usage:"
echo "  $0 backup [backup_dir]"
echo "  $0 restore [backup_dir|backup.tar.gz]"
exit 1
