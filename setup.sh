#!/usr/bin/env bash
# One-click setup: a fresh clone becomes a working `troupe` on your PATH, with
# the workflow skill installed for each harness it finds. Rerun to refresh.
#
#   ./setup.sh
#
# Steps: check prerequisites -> npm ci -> build & link -> troupe setup -> check.
set -euo pipefail
cd "$(dirname "$0")"

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
fail() { printf '\033[31m%s\033[0m\n' "$*" >&2; exit 1; }

# 1. Prerequisites
say '1/5  Checking prerequisites'
command -v node >/dev/null 2>&1 || fail 'node is missing; troupe needs Node.js 20+'
command -v npm  >/dev/null 2>&1 || fail 'npm is missing'
command -v git  >/dev/null 2>&1 || fail 'git is missing'
command -v tmux >/dev/null 2>&1 || fail 'tmux is missing; troupe runs each role in its own tmux window'
node_major="$(node -v | sed 's/^v//' | cut -d. -f1)"
[ "$node_major" -ge 20 ] || fail "node $(node -v) is too old; troupe needs Node.js 20+"
echo "node $(node -v) · npm $(npm -v) · git $(git --version | awk '{print $3}') · tmux $(tmux -V) — ok"

# 2. Dependencies
say '2/5  Installing dependencies'
npm ci

# 3. Build and link the command
say '3/5  Building and linking the `troupe` command'
npm run build
npm link

# 4. Install the workflow skill for each harness found
say '4/5  Installing the troupe-mission skill for each harness found'
hash -r 2>/dev/null || true
troupe setup

# 5. Verify: type-check, build and run the tests
say '5/5  Type-checking and running the tests'
./check.sh

say 'Done'
cat <<'EOF'
`troupe` is on your PATH and the troupe-mission skill is installed.

Next: open Claude Code or Codex inside tmux, in the repository you want to
change, and ask for a troupe mission. See docs/guide.md.
EOF