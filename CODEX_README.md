# MUSTAFAR PLAYBOOK — Codex Handoff README
## April 30, 2026 | Prepared for Zach Johnson

---

## What This Package Is

This is the complete Mustafar Server Conversion Playbook package. It includes:

- `mustafar_playbook.html` — The full playbook web page (5 tabs, self-contained HTML/CSS/JS)
- `scripts/` — Shell scripts for preflight, backup, and validation
- `config/Brewfile` — Homebrew bundle for server tooling
- `config/docker-compose.yml` — Monitoring stack (Portainer, Grafana, Prometheus, Uptime Kuma)

---

## What Changed in This Version

A new **"SSD & OS Upgrade"** tab has been added to the playbook. It contains the full
500GB → 1TB SSD migration and macOS Sequoia/OCLP upgrade guidebook, integrated into
the existing playbook design system.

**New tab added:** `SSD & OS Upgrade`
**New phases added:** Phase 0 through Phase 10 (inventory → validation)
**New scripts added:**
  - `scripts/ssd_phase0_preflight.sh`
  - `scripts/ssd_phase1_backup.sh`
  - `scripts/ssd_phase10_validate.sh`

---

## Codex Tasks

### 1. Serve / host the HTML
The `mustafar_playbook.html` file is fully self-contained. To serve it locally:
```bash
cd mustafar-playbook
python3 -m http.server 8080
# Then open http://localhost:8080/mustafar_playbook.html
```

### 2. Wire up the shell scripts as downloadable links (optional enhancement)
Each phase card in the "SSD & OS Upgrade" tab has a `phase-tag` label showing a script
filename (e.g., `scripts/ssd_phase0_preflight.sh`). If you want those to be clickable
download links in the HTML, add an `<a>` tag pointing to the script file.

Example — find the phase-tag for Phase 0 and update it:
```html
<!-- Before -->
<span class="phase-tag">scripts/ssd_phase0_preflight.sh</span>

<!-- After -->
<span class="phase-tag">
  <a href="scripts/ssd_phase0_preflight.sh" download style="color:inherit">
    scripts/ssd_phase0_preflight.sh ↓
  </a>
</span>
```

Do this for all three script references:
- Phase 0 → `scripts/ssd_phase0_preflight.sh`
- Phase 1 → `scripts/ssd_phase1_backup.sh`
- Phase 10 → `scripts/ssd_phase10_validate.sh`

### 3. Wire up the Server Conversion tab scripts (same pattern)
The Phase A–E cards in the "Server Conversion" tab reference:
- Phase A → `scripts/a_homebrew.sh` (not yet written; Codex can stub or implement)
- Phase B → `config/docker-compose.yml`
- Phase C → `scripts/c_tailscale.sh` (stub or implement)
- Phase D → `scripts/d_smb.sh` (stub or implement)
- Phase E → `scripts/e_launch.sh` (stub or implement)

### 4. Make the phase-tile cards on the Overview tab scroll-link to the right phase
Currently clicking a phase tile calls `switchTab('ssd-upgrade')` which switches tabs
but doesn't scroll to the specific phase. To also scroll, add a second step:

```javascript
function switchTab(id, phaseId) {
  // ... existing tab switch logic ...
  if (phaseId) {
    setTimeout(() => {
      const el = document.getElementById(phaseId);
      if (el) el.scrollIntoView({ behavior: 'smooth' });
    }, 100);
  }
}
```

Then give each phase card an `id` attribute (e.g., `id="phase-0"`) and update the
tile's onclick to pass it: `onclick="switchTab('ssd-upgrade', 'phase-0')"`.

### 5. (Optional) Add a print/PDF stylesheet
For printing a checklist version, add a `<link rel="stylesheet" media="print">` that:
- Shows only the active tab or all tabs
- Hides the nav and collapsible headers
- Expands all phase bodies

---

## File Structure
```
mustafar-playbook/
├── mustafar_playbook.html        ← Main page (hand off to hosting)
├── CODEX_README.md               ← This file
├── scripts/
│   ├── ssd_phase0_preflight.sh   ← Phase 0: inventory
│   ├── ssd_phase1_backup.sh      ← Phase 1: EFI backup
│   └── ssd_phase10_validate.sh   ← Phase 10: post-upgrade validation
└── config/
    ├── Brewfile                  ← Homebrew bundle
    └── docker-compose.yml        ← Monitoring stack
```

---

## Design System (for any additions)

The page uses a consistent set of CSS variables. Do not add colors outside this palette:

| Variable       | Value          | Use               |
|----------------|----------------|-------------------|
| `--ember`      | `#e8620a`      | Primary accent    |
| `--amber`      | `#f5a623`      | Secondary accent  |
| `--green`      | `#4ecb82`      | Success states    |
| `--red`        | `#e84848`      | Warning/error     |
| `--blue`       | `#5aa8f0`      | Info/links        |
| `--text`       | `#d4cfc8`      | Body text         |
| `--text-bright`| `#f0ebe3`      | Headings          |
| `--text-dim`   | `#7a7570`      | Muted text        |
| `--border`     | `#2a2a32`      | All borders       |
| `--surface`    | `#111114`      | Card backgrounds  |

Fonts: `Share Tech Mono` (code/labels) · `Barlow Condensed` (headings) · `Barlow` (body)

---

## Notes for Zach

- The old 500GB SSD should stay untouched until the 1TB install is proven stable for 1–2 weeks.
- macOS Sequoia via OCLP is the recommended OS target. Do not target Tahoe as the first attempt.
- Ethernet is required during install and patching. Wi‑Fi won't work until OCLP root patches are applied.
- Keep the OpenCore boot picker visible during the first few weeks for recovery access.
