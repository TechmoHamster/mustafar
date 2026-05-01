#!/bin/bash
# restic_backup.sh — Mustafar Automated Backup
# Schedule via launchd (see launchd/com.mustafar.backup.plist)
# Logs to: /var/log/mustafar/backup.log

# ── Configuration ─────────────────────────────────────────────
REPO_LOCAL="/Volumes/Mustafar-Archive/restic-repo"
# REPO_CLOUD="b2:mustafar-backup"          # uncomment for Backblaze B2

BACKUP_PATHS=(
  "/Volumes/Mustafar-Primary/RAW"
  "/Volumes/Mustafar-Primary/Selects"
  "/Volumes/Mustafar-Primary/Exports"
  "/Volumes/Mustafar-Primary/Archive"
)

EXCLUDE_PATTERNS=(
  "*.tmp"
  "*.DS_Store"
  "*.Spotlight-V100"
  "*/.Trashes"
  "*/node_modules"
  "*/__pycache__"
  "*/Library/Caches"
)

RETENTION_HOURLY=24      # keep last 24 hourly snapshots
RETENTION_DAILY=30       # keep last 30 daily snapshots
RETENTION_WEEKLY=12      # keep last 12 weekly snapshots

LOG_DIR="/var/log/mustafar"
LOG_FILE="$LOG_DIR/backup.log"
# ─────────────────────────────────────────────────────────────

mkdir -p "$LOG_DIR"

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"; }

log "=== Restic Backup Starting ==="

# Check repo is accessible
if [ ! -d "$REPO_LOCAL" ]; then
  log "❌ ERROR: Backup repo not found at $REPO_LOCAL"
  log "   Is the archive drive mounted? Check Disk Utility."
  osascript -e 'display notification "Backup repo not found — is the archive drive mounted?" with title "Mustafar — Backup Failed" sound name "Basso"' 2>/dev/null
  exit 1
fi

# Build exclude flags
EXCLUDE_FLAGS=()
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  EXCLUDE_FLAGS+=("--exclude=$pattern")
done

# Run backup
log "Backing up: ${BACKUP_PATHS[*]}"
restic -r "$REPO_LOCAL" backup \
  "${EXCLUDE_FLAGS[@]}" \
  --verbose \
  "${BACKUP_PATHS[@]}" \
  2>&1 | tee -a "$LOG_FILE"

BACKUP_EXIT=${PIPESTATUS[0]}

if [ $BACKUP_EXIT -eq 0 ]; then
  log "✅ Backup completed successfully."

  # Prune old snapshots
  log "Running retention policy..."
  restic -r "$REPO_LOCAL" forget \
    --keep-hourly  $RETENTION_HOURLY \
    --keep-daily   $RETENTION_DAILY  \
    --keep-weekly  $RETENTION_WEEKLY \
    --prune \
    2>&1 | tee -a "$LOG_FILE"

  # Show snapshot count
  SNAP_COUNT=$(restic -r "$REPO_LOCAL" snapshots --json 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "?")
  log "Total snapshots in repo: $SNAP_COUNT"

  osascript -e 'display notification "Backup completed successfully." with title "Mustafar — Backup OK"' 2>/dev/null
else
  log "❌ Backup FAILED with exit code $BACKUP_EXIT"
  osascript -e 'display notification "Backup failed — check /var/log/mustafar/backup.log" with title "Mustafar — Backup Failed" sound name "Basso"' 2>/dev/null
  exit $BACKUP_EXIT
fi

log "=== Restic Backup Complete ==="
