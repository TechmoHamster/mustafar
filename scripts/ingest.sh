#!/bin/bash
# ingest.sh — Mustafar Camera Card Ingest
# Automatically routes files from SD cards / camera mounts to /000_Ingest
# Safe: copies only — never deletes source files
# Trigger: run manually or via launchd volume-mount watcher

# ── Configuration ─────────────────────────────────────────────
INGEST_DIR="/Volumes/Mustafar-Primary/000_Ingest"
LOG_FILE="/var/log/mustafar/ingest.log"

# Camera card detection — DCIM folder is universal
DCIM_FOLDER="DCIM"

# File type routing (all go to Ingest first — sorted later manually)
PHOTO_EXTS=("arw" "cr2" "cr3" "nef" "dng" "rw2" "orf" "raf" "jpg" "jpeg" "heic")
VIDEO_EXTS=("mp4" "mov" "mxf" "r3d" "braw" "avi" "mkv")
# ─────────────────────────────────────────────────────────────

mkdir -p "$INGEST_DIR"
mkdir -p "$(dirname $LOG_FILE)"

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"; }

log "=== Ingest Script Starting ==="

COPIED=0
SKIPPED=0
ERRORS=0

# Scan all mounted volumes for DCIM folders
for VOLUME in /Volumes/*/; do
  DCIM_PATH="${VOLUME}${DCIM_FOLDER}"

  if [ ! -d "$DCIM_PATH" ]; then
    continue
  fi

  VOLUME_NAME=$(basename "$VOLUME")
  log "📷 Camera card detected: $VOLUME_NAME ($DCIM_PATH)"

  # Find all media files
  while IFS= read -r -d '' FILE; do
    FILENAME=$(basename "$FILE")
    EXT="${FILENAME##*.}"
    EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')
    DEST="$INGEST_DIR/$FILENAME"

    # Skip if already copied (by filename — simple dedup)
    if [ -f "$DEST" ]; then
      log "  ↷ Skipping (exists): $FILENAME"
      ((SKIPPED++))
      continue
    fi

    # Copy file
    log "  → Copying: $FILENAME"
    cp "$FILE" "$DEST"

    if [ $? -eq 0 ]; then
      ((COPIED++))
    else
      log "  ❌ ERROR copying: $FILENAME"
      ((ERRORS++))
    fi

  done < <(find "$DCIM_PATH" -type f \( \
    -iname "*.arw" -o -iname "*.cr2" -o -iname "*.cr3" -o -iname "*.nef" \
    -o -iname "*.dng" -o -iname "*.rw2" -o -iname "*.jpg" -o -iname "*.jpeg" \
    -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mxf" -o -iname "*.r3d" \
    -o -iname "*.braw" -o -iname "*.heic" -o -iname "*.raf" -o -iname "*.orf" \
  \) -print0)

done

log "=== Ingest Complete: $COPIED copied · $SKIPPED skipped · $ERRORS errors ==="

if [ $COPIED -gt 0 ]; then
  osascript -e "display notification \"Ingested $COPIED files → /000_Ingest\" with title \"Mustafar — Ingest Complete\"" 2>/dev/null
fi

if [ $ERRORS -gt 0 ]; then
  osascript -e "display notification \"$ERRORS errors during ingest — check logs\" with title \"Mustafar — Ingest Warning\" sound name \"Basso\"" 2>/dev/null
fi
