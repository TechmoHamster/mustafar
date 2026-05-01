# Mustafar Bootstrap Brewfile
# Mac Pro 5,1 · macOS Monterey via OpenCore
# Run: brew bundle --file=Brewfile

# ── Core CLI Tools ──────────────────────────────
brew "git"
brew "curl"
brew "wget"
brew "htop"
brew "neofetch"
brew "tree"
brew "jq"
brew "rsync"
brew "watch"
brew "tmux"

# ── Disk Health ──────────────────────────────────
brew "smartmontools"         # smartctl -a /dev/disk0

# ── Backups ──────────────────────────────────────
brew "restic"                # encrypted, deduplicated backups

# ── Networking ───────────────────────────────────
brew "cloudflared"           # Cloudflare Tunnel
cask "tailscale"             # machine-level remote access

# ── Container Runtime ────────────────────────────
# Option A: OrbStack (lighter, test on OpenCore first)
cask "orbstack"
# Option B: Docker Desktop (fallback if OrbStack has issues)
# cask "docker"

# ── Development ──────────────────────────────────
brew "node"
brew "python@3.11"
brew "git-lfs"
cask "visual-studio-code"

# ── Utilities ────────────────────────────────────
cask "iterm2"                # better terminal
