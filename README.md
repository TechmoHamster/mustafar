# Mustafar Playbook

Static browser app for the Mustafar project: Mac Pro 5,1 server conversion, 500GB → 1TB SSD migration, and OCLP/macOS upgrade planning.

## Open the app

### Option 1 — Open directly
Open this file in a browser:

```text
mustafar_playbook.html
```

### Option 2 — Run locally
From the repo root:

```bash
npm run dev
```

Then open:

```text
http://localhost:8080
```

The root `index.html` automatically redirects to `mustafar_playbook.html`.

## Validate the repo

```bash
npm run validate
```

The validator checks for:

- `index.html`
- `mustafar_playbook.html`
- required SSD helper scripts
- required config files
- the Prometheus config referenced by `config/docker-compose.yml`
- key HTML snippets needed for the playbook UI

## Main files

| File | Purpose |
|---|---|
| `index.html` | Static site entry point. Redirects to the playbook. |
| `mustafar_playbook.html` | Main self-contained browser app. |
| `CODEX_README.md` | Codex handoff notes and implementation guidance. |
| `package.json` | Local scripts for serving and validation. |
| `scripts/validate_site.mjs` | Static validation script. |
| `config/Brewfile` | v2 Homebrew bundle. |
| `config/docker-compose.yml` | v2 monitoring stack. |
| `config/prometheus.yml` | Prometheus scrape config used by the compose stack. |
| `scripts/ssd_phase0_preflight.sh` | SSD upgrade preflight inventory helper. |
| `scripts/ssd_phase1_backup.sh` | EFI/OpenCore backup helper. |
| `scripts/ssd_phase10_validate.sh` | Post-upgrade validation helper. |

## GitHub Pages setup

The app is now structured so GitHub Pages can serve it from the repository root.

In GitHub:

1. Open the repo settings.
2. Go to **Pages**.
3. Under **Build and deployment**, choose **Deploy from a branch**.
4. Branch: `main`.
5. Folder: `/root`.
6. Save.

Once Pages finishes, GitHub will provide the public URL.

## Docker monitoring stack

Start the v2 monitoring stack:

```bash
docker compose -f config/docker-compose.yml up -d
```

This includes:

- Portainer
- Prometheus
- Grafana
- Uptime Kuma

Default local URLs:

```text
Portainer:   http://localhost:9000 or https://localhost:9443
Prometheus:  http://localhost:9090
Grafana:     http://localhost:3000
Uptime Kuma: http://localhost:3001
```

Change any default passwords before exposing services beyond localhost.

## Notes

- The browser checklist progress is stored in localStorage.
- The playbook is intentionally static; it does not need a backend server.
- Keep the old 500GB SSD untouched for 1–2 weeks after the 1TB SSD upgrade is validated.
