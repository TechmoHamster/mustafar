# Mustafar Playbook

Operational playbook and automation helpers for the Mustafar server conversion and SSD/OS migration.

## What's Included

- `mustafar_playbook.html` — self-contained web playbook with checklists, command blocks, and progress tracking.
- `scripts/` — operational scripts for backup, SMART checks, ingest, and migration phases.
- `config/` — compose and supporting config.
- `launchd/` — example LaunchAgent plists.
- `docker/` — optional compose stacks for dev/monitoring/AI tooling.

## Quick Start

1. Clone and open the repo.
2. Serve the playbook locally:

```bash
python3 -m http.server 8080
# open http://localhost:8080/mustafar_playbook.html
```

3. Make scripts executable:

```bash
chmod +x scripts/*.sh
```

## Publishing

Because the playbook is a single static HTML file, you can publish with any static host:

- GitHub Pages
- Cloudflare Pages
- Netlify
- S3 + CloudFront

Recommended: publish the entire repo folder so script download links remain functional.

## Completed Readiness Tasks

- Added script download links to phase cards in SSD and Server tabs.
- Added and wired missing Server Conversion script stubs:
  - `scripts/a_homebrew.sh`
  - `scripts/c_tailscale.sh`
  - `scripts/d_smb.sh`
  - `scripts/e_launch.sh`
- Overview tiles now deep-link into the correct phase section within each tab.

## Notes

- This project targets macOS operational workflows (`diskutil`, `launchctl`, `osascript`, Homebrew).
- Review and customize script defaults before production use.
- Keep backups external to the active boot volume.
