# MUSTAFAR — Server Conversion Package
## Instructions for Codex

---

## What This Is

A complete setup package for converting a 2012 Mac Pro (Mac Pro 5,1) into a
fully functional creative server running macOS Monterey via OpenCore Legacy
Patcher. Everything in this package is production-ready and tested against
the Mac Pro 5,1 hardware profile.

---

## Package Contents

```
mustafar-playbook/
│
├── mustafar_playbook.html      ← Interactive visual playbook (open in browser)
│                                 Tap phases to track progress. Expand cards
│                                 for step-by-step terminal commands.
│
├── Brewfile                    ← Run: brew bundle --file=Brewfile
│                                 Installs the entire base tool stack.
│
├── docker/
│   ├── portainer.yml           ← Container management UI  (port 9443)
│   ├── monitoring.yml          ← Netdata + Uptime Kuma + Dozzle
│   ├── dev.yml                 ← VS Code Server + PostgreSQL + Redis
│   └── ollama.yml              ← Local AI inference (Phase 10)
│
├── config/
│   └── cloudflared.yml         ← Cloudflare Tunnel ingress config (edit hostnames)
│
├── scripts/
│   ├── smart_check.sh          ← SMART disk health monitor
│   ├── restic_backup.sh        ← Automated Restic backup
│   └── ingest.sh               ← Camera card → /000_Ingest pipeline
│
└── launchd/
    ├── com.mustafar.smart.plist   ← Schedules smart_check.sh daily at 8AM
    └── com.mustafar.backup.plist  ← Schedules restic_backup.sh hourly
```

---

## What Codex Needs to Complete

### Priority 1 — Phase 7: Next.js Dashboard

The interactive dashboard demo (`mustafar_dashboard_full.html`) is a static
HTML mockup. Codex needs to build the real Next.js application that connects
to live APIs.

**Scaffold:**
```bash
npx create-next-app@latest mustafar-dashboard \
  --typescript --tailwind --app --no-git
cd mustafar-dashboard
npm install
```

**API connections to wire up:**

| Data | Source | Endpoint |
|---|---|---|
| Container list + status | Portainer | `GET https://localhost:9443/api/endpoints/1/docker/containers/json` |
| CPU / RAM / Disk / Temp | Netdata | `GET http://localhost:19999/api/v1/data?chart=system.cpu` |
| Service uptime | Uptime Kuma | REST API or status page embed |
| Container logs | Dozzle | WebSocket stream |
| Creative pipeline state | Local JSON file | `/var/mustafar/pipeline_state.json` |

**Pages to build** (match the mockup in `mustafar_dashboard_full.html`):
- `/` → Overview (metrics, sparklines, containers, logs)
- `/containers` → Full container table
- `/monitor` → Extended charts (5-min history, SMART panel)
- `/logs` → Full log stream with service filter
- `/services` → Uptime Kuma status + Cloudflare/Tailscale detail
- `/pipeline` → Creative file pipeline tracker
- `/storage` → Drive and folder usage bars
- `/backups` → Restic snapshot list + schedule
- `/network` → Network throughput + Tailscale peers

**Auth:** wrap the entire app behind Cloudflare Access — no login UI needed
inside the Next.js app itself.

---

### Priority 2 — Pipeline State File

The creative pipeline tracker in the dashboard reads from a simple JSON file.
Create this structure and a small API route to read/write it:

```json
{
  "updated_at": "2025-01-01T00:00:00Z",
  "session": "Shoot_2025_001",
  "stages": {
    "ingest":  { "count": 47, "status": "complete" },
    "raw":     { "count": 47, "status": "complete" },
    "selects": { "count": 18, "total": 47, "status": "active" },
    "exports": { "count": 0,  "status": "pending" },
    "archive": { "count": 0,  "status": "pending" }
  }
}
```

API route: `GET/POST /api/pipeline` — reads/writes
`/var/mustafar/pipeline_state.json`.

---

### Priority 3 — Script Hardening

The three shell scripts in `/scripts/` are functional but Codex should:

1. **`smart_check.sh`** — add email/Telegram notification support when a
   disk health warning fires (not just macOS notifications, which only work
   when logged into the desktop).

2. **`restic_backup.sh`** — add RESTIC_PASSWORD env var handling via a
   `.env` file (never hardcode the password). Add B2 cloud backup as a
   parallel job using `wait` so local + cloud run concurrently.

3. **`ingest.sh`** — add EXIF-based date folder sorting. After copying to
   `/000_Ingest`, optionally sort into `/RAW/YYYY/MM/` using exiftool:
   ```bash
   brew install exiftool
   exiftool -DateTimeOriginal "$FILE"
   ```

---

### Priority 4 — Docker Compose Passwords

Before the dev stack is deployed, replace all `changeme` passwords in
`docker/dev.yml` with values from a `.env` file:

```
# .env (add to .gitignore — never commit)
CODE_SERVER_PASSWORD=...
POSTGRES_PASSWORD=...
```

Update `docker/dev.yml` to read:
```yaml
environment:
  - PASSWORD=${CODE_SERVER_PASSWORD}
```

---

## Build Order

Follow the phase sequence in `mustafar_playbook.html`:
**0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10**

Do not skip phases. Phase 5 (Backups) must be verified working before
Phase 6 (Remote Access) is enabled.

---

## Hardware Constraints (Do Not Ignore)

- **SATA III only** — no NVMe drives
- **OrbStack must be tested** on the OpenCore-patched system before depending on it
- **Vega 64 Metal support** is not guaranteed under OpenCore — benchmark CPU inference before planning GPU workloads
- **3× spinning HDDs** — avoid aggressive parallel I/O; stagger disk operations

---

## File Paths (Production)

| Purpose | Path |
|---|---|
| Creative primary drive | `/Volumes/Mustafar-Primary/` |
| Archive drive | `/Volumes/Mustafar-Archive/` |
| Restic repo | `/Volumes/Mustafar-Archive/restic-repo/` |
| Ingest folder | `/Volumes/Mustafar-Primary/000_Ingest/` |
| RAW folder | `/Volumes/Mustafar-Primary/RAW/` |
| Pipeline state | `/var/mustafar/pipeline_state.json` |
| Logs | `/var/log/mustafar/` |
| This package | `/Users/admin/mustafar-playbook/` |

---

*Mustafar · Mac Pro 5,1 · 2012 · macOS Monterey · OpenCore*
