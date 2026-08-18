#!/usr/bin/env bash
# Install dcltdw's shared Claude rules so they load in every project on this
# machine — regardless of where this repo is cloned.
#
# Idempotent: safe to re-run (e.g. after `git pull`). Run once per machine:
#     ./install.sh
#
# Verify an existing install without changing anything (read-only):
#     ./install.sh --check
#
# The `claude` CLI does not have to be on PATH — a VS Code-only install ships
# it inside the extension and never adds it. Point at it explicitly with:
#     CLAUDE_BIN=/path/to/claude ./install.sh
#
# Exits non-zero if any part of the install could not be completed, so a
# partial install is visible to whatever ran this.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$REPO_DIR/claude"

CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
LINK="$CLAUDE_HOME/dcltdw"                     # stable path, independent of clone location
GLOBAL_MD="$CLAUDE_HOME/CLAUDE.md"
IMPORT='@~/.claude/dcltdw/AGENTS.md'           # canonical import
LEGACY='@~/Github/dcltdw/claude/universal.md'  # old hardcoded-path import to migrate

usage() {
  echo "usage: ./install.sh [--check]"
  echo "  (no args)  install/update: symlink, global import, skills plugin, pre-push hook"
  echo "  --check    verify an existing install; changes nothing, exits non-zero on any mismatch"
  echo "environment:"
  echo "  CLAUDE_BIN  path to the 'claude' CLI, if it is not on PATH"
}

MODE=install
case "${1:-}" in
  "")        ;;
  --check)   MODE=check ;;
  -h|--help) usage; exit 0 ;;
  *)         echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
esac

# --- helpers ---------------------------------------------------------------

# Resolve the `claude` CLI without assuming it is on PATH. "Is claude on PATH"
# and "can I run claude" are different questions on a VS Code-only install,
# where the binary lives inside the extension. CLAUDE_BIN is checked first so
# an unanticipated layout (JetBrains, a native installer under ~/.local/bin)
# has an escape hatch that needs no edit to this script. Prints the path.
resolve_claude() {
  if [ -n "${CLAUDE_BIN:-}" ]; then
    if [ -x "$CLAUDE_BIN" ]; then
      printf '%s\n' "$CLAUDE_BIN"
      return 0
    fi
    echo "WARNING: CLAUDE_BIN='$CLAUDE_BIN' is not an executable file — ignoring it." >&2
  fi
  command -v claude 2>/dev/null && return 0
  # Several extension versions coexist and the newest is the one to use, so
  # sort by version, not lexically (1.10.0 must beat 1.2.3). Walk the matches
  # newest-first and take the first *executable* one, rather than testing only
  # the newest: a half-installed or broken newest version must not mask an
  # older one that still works.
  local candidates c
  candidates="$(ls -d "$HOME"/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude 2>/dev/null | sort -Vr || true)"
  [ -n "$candidates" ] || return 1
  while IFS= read -r c; do
    if [ -n "$c" ] && [ -x "$c" ]; then
      printf '%s\n' "$c"
      return 0
    fi
  done <<EOF
$candidates
EOF
  return 1
}

# True if two directory paths name the same directory. Compares the literal
# strings first, then canonicalises *both* sides. Canonicalising both is the
# only comparison that holds regardless of which form each side happens to be
# recorded in: `$REPO_DIR` and the registered marketplace path are logical
# (whatever path install.sh was invoked through), while a resolved symlink is
# physical — so on the common layout where ~/Github is itself a symlink onto
# another volume, comparing one against the other would report a bogus
# mismatch. Switching linked_repo() to a logical `pwd` alone would not fix
# that: it would only work when both sides were recorded through the same
# path spelling.
same_dir() {
  [ "$1" = "$2" ] && return 0
  local a b
  a="$(cd "$1" 2>/dev/null && pwd -P || true)"
  b="$(cd "$2" 2>/dev/null && pwd -P || true)"
  [ -n "$a" ] && [ "$a" = "$b" ]
}

# Extracts the registered path of the "dcltdw" marketplace. Handles both the
# CLI's `--json` listing (an array) and Claude Code's own state file (an
# object keyed by marketplace name).
MP_PY='
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    data = None
path = ""
if isinstance(data, list):
    for m in data:
        if isinstance(m, dict) and m.get("name") == "dcltdw":
            path = m.get("path") or m.get("installLocation") or ""
elif isinstance(data, dict):
    m = data.get("dcltdw")
    if isinstance(m, dict):
        path = (m.get("source") or {}).get("path") or m.get("installLocation") or ""
print(path)
sys.exit(0 if path else 1)
'

# Where the "dcltdw" marketplace currently points, or empty if unregistered.
# Detect registration by NAME *and* PATH via `--json`, not a text grep on the
# plain listing. Matching name alone means a moved clone (or a second clone on
# this machine) looks "already registered" and takes the `update` branch below
# against its old/other path — which fails and, if unguarded, would abort the
# whole install under `set -euo pipefail`.
# Falls back to Claude Code's state file so the remediation line stays precise
# (and `--check` stays useful) even when the binary cannot be run at all.
marketplace_path() {
  local bin="${1:-}" out=""
  if [ -n "$bin" ]; then
    out="$("$bin" plugin marketplace list --json 2>/dev/null | python3 -c "$MP_PY" 2>/dev/null || true)"
  fi
  if [ -z "$out" ] && [ -r "$CLAUDE_HOME/plugins/known_marketplaces.json" ]; then
    out="$(python3 -c "$MP_PY" < "$CLAUDE_HOME/plugins/known_marketplaces.json" 2>/dev/null || true)"
  fi
  printf '%s\n' "$out"
  [ -n "$out" ]
}

# The clone that the *installed* symlink points into (not necessarily this one).
linked_repo() {
  local rules
  rules="$(cd "$LINK" 2>/dev/null && pwd -P || true)"
  [ -n "$rules" ] || return 1
  dirname "$rules"
}

status=0
PARTIAL=""
# Record a step that was skipped or failed: sets the exit status and adds a
# line to the closing summary, so a partial install names its own remedy.
note_partial() {
  status=1
  PARTIAL="${PARTIAL}  - $1
"
}

# --- --check: verify the four consumers, change nothing ---------------------

run_check() {
  local rc=0 tgt lrepo mp hp bin
  echo "checking install (read-only) — config dir: $CLAUDE_HOME"

  # 1) symlink target
  if [ -L "$LINK" ]; then
    tgt="$(readlink "$LINK" || true)"
    if [ -d "$LINK/" ]; then
      echo "  ok    symlink   $LINK -> $tgt"
    else
      echo "  FAIL  symlink   $LINK -> $tgt (target does not exist — dangling)" >&2
      rc=1
    fi
  elif [ -e "$LINK" ]; then
    echo "  FAIL  symlink   $LINK exists but is not a symlink" >&2
    rc=1
  else
    echo "  FAIL  symlink   $LINK is missing — run ./install.sh" >&2
    rc=1
  fi

  # 2) the imported rules file is readable through that symlink
  if [ -r "$GLOBAL_MD" ] && grep -qF "$IMPORT" "$GLOBAL_MD"; then
    if [ -r "$LINK/AGENTS.md" ]; then
      echo "  ok    rules     $GLOBAL_MD imports $IMPORT (readable)"
    else
      echo "  FAIL  rules     $GLOBAL_MD imports $IMPORT but $LINK/AGENTS.md is not readable" >&2
      rc=1
    fi
  else
    echo "  FAIL  rules     $GLOBAL_MD does not import $IMPORT — run ./install.sh" >&2
    rc=1
  fi

  # 3) marketplace path — must agree with the symlink, or the machine is
  #    half-migrated: rules from one clone, skills from another.
  bin="$(resolve_claude || true)"
  mp="$(marketplace_path "$bin" || true)"
  lrepo="$(linked_repo || true)"
  echo "  note  claude    ${bin:-<not found — set CLAUDE_BIN to point at it>}"
  if [ -z "$mp" ]; then
    if [ -z "$bin" ]; then
      echo "  FAIL  plugin    'dcltdw' marketplace not registered, and no 'claude' CLI to ask" >&2
      echo "                  (set CLAUDE_BIN=/path/to/claude to check properly)" >&2
    else
      echo "  FAIL  plugin    'dcltdw' marketplace is not registered — run ./install.sh" >&2
    fi
    rc=1
  elif [ -n "$lrepo" ] && ! same_dir "$mp" "$lrepo"; then
    echo "  FAIL  plugin    'dcltdw' marketplace points at $mp, but $LINK points into $lrepo" >&2
    echo "                  (half-migrated: re-run ./install.sh from $lrepo)" >&2
    rc=1
  else
    echo "  ok    plugin    'dcltdw' marketplace -> $mp"
  fi

  # 4) core.hooksPath resolves to a usable hook dir
  hp="$(git config --global --get core.hooksPath || true)"
  if [ -z "$hp" ]; then
    echo "  FAIL  hooks     global core.hooksPath is not set — pre-push secrets scan not installed" >&2
    rc=1
  elif [ "$hp" = "$LINK/githooks" ]; then
    if [ -x "$hp/pre-push" ]; then
      echo "  ok    hooks     core.hooksPath -> $hp"
    else
      echo "  FAIL  hooks     core.hooksPath -> $hp but $hp/pre-push is missing or not executable" >&2
      rc=1
    fi
  else
    # install.sh deliberately never overrides a custom hooksPath, so this is a
    # supported configuration, not a failure. See claude/ADOPTING.md.
    echo "  note  hooks     core.hooksPath is '$hp', not $LINK/githooks — install.sh never overrides it;"
    echo "                  chain $LINK/githooks/pre-push from your own hooks to get the secrets scan."
  fi
  command -v gitleaks >/dev/null 2>&1 || echo "  note  gitleaks not installed (brew install gitleaks) — the hook will warn, not scan."

  echo
  if [ "$rc" = 0 ]; then
    echo "check passed."
  else
    echo "check FAILED — see the FAIL lines above." >&2
  fi
  return "$rc"
}

if [ "$MODE" = check ]; then
  run_check
  exit $?
fi

# --- install ---------------------------------------------------------------

mkdir -p "$CLAUDE_HOME"

# 1) Point a stable path at the rules dir, so imports never hardcode the clone location.
#    This runs even if the plugin half below cannot: rules delivery is the more
#    important half and is correct on its own.
ln -sfn "$RULES_DIR" "$LINK"
echo "linked $LINK -> $RULES_DIR"

# 2) Ensure the machine-global user memory imports the rules.
touch "$GLOBAL_MD"
if grep -qF "$IMPORT" "$GLOBAL_MD"; then
  echo "global import already present ($GLOBAL_MD)"
elif grep -qF "$LEGACY" "$GLOBAL_MD"; then
  cp "$GLOBAL_MD" "$GLOBAL_MD.bak"
  awk -v old="$LEGACY" -v new="$IMPORT" '{print ($0==old ? new : $0)}' "$GLOBAL_MD" > "$GLOBAL_MD.tmp"
  mv "$GLOBAL_MD.tmp" "$GLOBAL_MD"
  echo "migrated legacy import -> $IMPORT (backup: $GLOBAL_MD.bak)"
else
  printf '\n# Shared collaboration rules (dcltdw)\n%s\n' "$IMPORT" >> "$GLOBAL_MD"
  echo "added import to $GLOBAL_MD"
fi

# 3) Register the skills-plugin marketplace and install/update the plugin.
CLAUDE_CLI="$(resolve_claude || true)"
if [ -n "$CLAUDE_CLI" ]; then
  echo "using claude CLI: $CLAUDE_CLI"
  # `marketplace add` is safe to call even when a marketplace named "dcltdw"
  # already exists elsewhere: it either no-ops ("already on disk") or re-points
  # that registration at this clone — exactly the recovery this repo's docs
  # promise when you move the clone.
  mp_ok=1
  if [ "$(marketplace_path "$CLAUDE_CLI" || true)" = "$REPO_DIR" ]; then
    "$CLAUDE_CLI" plugin marketplace update dcltdw || mp_ok=0
  else
    "$CLAUDE_CLI" plugin marketplace add "$REPO_DIR" || mp_ok=0
  fi

  if [ "$mp_ok" = 1 ]; then
    # `plugin install` is a no-op once installed and never picks up a version
    # bump on its own; `plugin update` is what actually refreshes the cached
    # copy, but it errors if the plugin isn't installed yet — so run both:
    # install covers first-time setup, update covers picking up new content.
    plugin_ok=1
    "$CLAUDE_CLI" plugin install dcltdw@dcltdw || plugin_ok=0
    "$CLAUDE_CLI" plugin update dcltdw@dcltdw || plugin_ok=0
    if [ "$plugin_ok" = 1 ]; then
      echo "skills plugin dcltdw installed/updated"
    else
      echo "WARNING: failed to install/update the dcltdw skills plugin — see output above." >&2
      note_partial "skills plugin dcltdw NOT installed/updated — see the output above, then re-run ./install.sh"
    fi
  else
    echo "WARNING: failed to register/update the dcltdw plugin marketplace — skills plugin NOT installed/updated." >&2
    note_partial "'dcltdw' plugin marketplace NOT registered at $REPO_DIR — see the output above, then re-run ./install.sh"
  fi
else
  mp_now="$(marketplace_path "" || true)"
  echo "WARNING: could not find the 'claude' CLI — skills plugin NOT installed/updated." >&2
  echo "         A VS Code-only install does not put 'claude' on PATH, and no usable" >&2
  echo "         binary was found under ~/.vscode/extensions/anthropic.claude-code-*/" >&2
  echo "         either. Install Claude Code, or point at the binary explicitly:" >&2
  echo "             CLAUDE_BIN=/path/to/claude ./install.sh" >&2
  note_partial "symlink updated to $RULES_DIR, but the 'dcltdw' plugin marketplace still points at ${mp_now:-<not registered>} — re-run with CLAUDE_BIN=/path/to/claude ./install.sh"
fi

# 4) Global pre-push secrets scan (gitleaks) via core.hooksPath.
existing="$(git config --global --get core.hooksPath || true)"
if [ -z "$existing" ] || [ "$existing" = "$LINK/githooks" ]; then
  if git config --global core.hooksPath "$LINK/githooks"; then
    echo "global core.hooksPath -> $LINK/githooks (pre-push secrets scan)"
    echo "WARNING: this arms core.hooksPath machine-wide, which makes git stop" >&2
    echo "         running any repo-local hook type OTHER than pre-push — in" >&2
    echo "         EVERY repo on this machine, not just this one. pre-commit," >&2
    echo "         commit-msg, post-checkout, post-merge, post-commit, etc. in" >&2
    echo "         repo-local .git/hooks/ will silently stop firing (common" >&2
    echo "         casualties: the pre-commit framework, commit-msg linters)." >&2
    echo "         See claude/ADOPTING.md for details." >&2
  else
    echo "WARNING: failed to set global core.hooksPath — pre-push secrets scan NOT installed." >&2
    note_partial "global core.hooksPath NOT set to $LINK/githooks — the pre-push secrets scan will not run"
  fi
else
  # Not a failure: refusing to clobber a custom hooksPath is the documented
  # behaviour an adopter opted into, not a step that went wrong.
  echo "WARNING: core.hooksPath already set to '$existing' — NOT overriding."
  echo "         To get the secrets scan, chain $LINK/githooks/pre-push from your hooks."
fi
command -v gitleaks >/dev/null 2>&1 || echo "NOTE: gitleaks not installed (brew install gitleaks) — the hook will warn, not scan."

echo
if [ "$status" = 0 ]; then
  echo "Done. Start a new Claude session (or /clear) to pick up the rules."
  echo "Garmin repos: add the release supplement + dcltdw:garmin-release skill pointer to that repo's CLAUDE.md (see claude/ADOPTING.md)."
else
  echo "INCOMPLETE — this machine is only partly set up:" >&2
  printf '%s' "$PARTIAL" >&2
  echo "  Verify with: ./install.sh --check" >&2
fi
exit "$status"
