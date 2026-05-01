#!/bin/bash
# smart_check.sh — Mustafar SMART Disk Health Monitor
# Run manually or schedule via launchd (see launchd/com.mustafar.smart.plist)
# Logs to: /var/log/mustafar/smart_check.log

LOG_DIR="/var/log/mustafar"
LOG_FILE="$LOG_DIR/smart_check.log"
ALERT_TEMP=55    # °C — alert threshold
FAIL_KEYWORD="FAILED"

mkdir -p "$LOG_DIR"

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

log() { echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"; }

log "=== SMART Check Starting ==="

# Auto-detect all physical disks
DISKS=$(diskutil list | grep "^/dev/disk" | grep -v "synthesized" | awk '{print $1}')

ALL_HEALTHY=true

for DISK in $DISKS; do
  log "Checking $DISK..."

  # Overall health
  HEALTH=$(smartctl -H "$DISK" 2>/dev/null | grep "SMART overall-health")
  if echo "$HEALTH" | grep -q "$FAIL_KEYWORD"; then
    log "⚠️  WARNING: $DISK health check FAILED — $HEALTH"
    ALL_HEALTHY=false
  else
    log "✅ $DISK: $HEALTH"
  fi

  # Temperature
  TEMP=$(smartctl -A "$DISK" 2>/dev/null | grep -i "temperature" | awk '{print $10}' | head -1)
  if [ -n "$TEMP" ]; then
    if [ "$TEMP" -gt "$ALERT_TEMP" ] 2>/dev/null; then
      log "🌡️  WARNING: $DISK temperature is ${TEMP}°C (threshold: ${ALERT_TEMP}°C)"
      ALL_HEALTHY=false
    else
      log "🌡️  $DISK temperature: ${TEMP}°C — OK"
    fi
  fi

  # Reallocated sectors (early failure indicator)
  REALLOCATED=$(smartctl -A "$DISK" 2>/dev/null | grep "Reallocated_Sector_Ct" | awk '{print $10}')
  if [ -n "$REALLOCATED" ] && [ "$REALLOCATED" -gt 0 ] 2>/dev/null; then
    log "⚠️  WARNING: $DISK has $REALLOCATED reallocated sectors — drive may be failing"
    ALL_HEALTHY=false
  fi

done

if $ALL_HEALTHY; then
  log "✅ All disks healthy."
else
  log "⚠️  One or more disk warnings detected. Review log: $LOG_FILE"
  # Optional: send a macOS notification
  osascript -e 'display notification "SMART disk warning detected on Mustafar. Check logs." with title "Mustafar — Disk Alert" sound name "Basso"' 2>/dev/null
fi

log "=== SMART Check Complete ==="
