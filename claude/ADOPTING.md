# Adopting dcltdw's shared Claude rules

The canonical shared rules live in this directory: **[`AGENTS.md`](AGENTS.md)**
— cross-project collaboration rules, in the vendor-neutral
[AGENTS.md](https://agents.md/) format. The PR-lifecycle and Garmin-release
skills ship separately, via the `dcltdw` plugin (see Delivery paths).

## Install (once per machine)

From a clone of this repo:

    ./install.sh

The script is idempotent and does four things:

- symlinks this `claude/` directory to the stable path `~/.claude/dcltdw`, so
  imports don't depend on *where* you cloned the repo — re-run `./install.sh`
  if you move the clone; both the symlink and the plugin marketplace
  registration re-point at the new location;
- ensures your machine-global `~/.claude/CLAUDE.md` imports the universal rules:

      @~/.claude/dcltdw/AGENTS.md

  (migrating the old `@~/Github/dcltdw/claude/universal.md` import if it finds it);
- registers this clone as the `dcltdw` plugin marketplace and installs the
  `dcltdw` skills plugin — home to this repo's PR-lifecycle skills,
  `dcltdw:opening-a-pr` and `dcltdw:cleaning-up-after-pr-merge`, and the
  release procedure, `dcltdw:garmin-release`;
- `install.sh` also points `core.hooksPath` at a global pre-push hook that
  runs gitleaks (`brew install gitleaks`) over outgoing commits; it refuses
  to override a pre-existing custom `core.hooksPath` and warns instead. A
  push from a GUI git client or IDE may run with a reduced `PATH` that
  doesn't include `gitleaks`, in which case the hook warns — but GUI clients
  generally don't surface hook stderr, so in that exact scenario the warning
  itself is invisible and the push goes through unscanned with nothing shown.

**If the `claude` CLI isn't on your `PATH` — e.g. a VS Code-only install.**
The VS Code extension ships the CLI *inside the extension* and never adds it
to `PATH`, so "is `claude` on `PATH`" is not the same question as "can I run
`claude`". `install.sh` resolves the binary rather than requiring `PATH`, in
this order: `$CLAUDE_BIN`, then `PATH`, then the newest
`~/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude`.
On a layout it doesn't know about (JetBrains, a native installer under
`~/.local/bin`), point it at the binary yourself:

    CLAUDE_BIN=/path/to/claude ./install.sh

If it finds no usable binary it still re-points the `~/.claude/dcltdw`
symlink — rules delivery is the more important half and is correct on its own
— but the plugin marketplace is then left pointing wherever it pointed
before. That half-migrated state is exactly what used to pass silently, so the
script now names the inconsistency, prints the `CLAUDE_BIN` remedy, and
**exits non-zero**. Anything that runs `install.sh` unattended should check
its exit status.

**To verify a machine without changing it:**

    ./install.sh --check

It makes no writes — no symlink, no `git config --global <name> <value>`, no
mutating `claude plugin` subcommand; it only reads (`readlink`, `git config
--global --get`, `claude plugin marketplace list`). It checks the four things
an install has to get right — the `~/.claude/dcltdw` symlink resolves,
`~/.claude/CLAUDE.md` imports rules that are actually readable through it, the
`dcltdw` plugin marketplace points at the same clone the symlink does, and
`core.hooksPath` resolves to a usable `pre-push` hook — and exits non-zero
naming any that don't. It also reports which `claude` binary it resolved,
which is the first thing you want when the plugin line looks wrong. A
marketplace pointing somewhere other than the symlink's clone is the
half-migration above. A custom `core.hooksPath` (see below) is reported as a
note, not a failure, since `install.sh` deliberately never overrides one.

An unrecognised argument is a usage error: the script prints usage and exits
**2**, so a typo (`--chekc`) can never be mistaken for "run the install".

**Setting `core.hooksPath` globally is a real trade-off — read this before
running `install.sh`:**

- **It silently disables every other repo-local hook type, in every repo on
  this machine, not just this one.** Git only consults one `hooksPath` at a
  time. Once it's set globally, a repo's own `.git/hooks/pre-commit`,
  `commit-msg`, `post-checkout`, `post-merge`, `post-commit`, etc. **stop
  running, with no error from git.** Only `pre-push` still works, because
  `claude/githooks/pre-push` explicitly chains to the repo-local
  `hooks/pre-push` after scanning — no other hook type is chained. This
  breaks `pre-commit`-framework repos, commit-msg linters, and any non-push
  git-lfs hook. Nothing else warns you this happened; it just quietly stops.
- **A repo with its own `core.hooksPath` (repo-local `git config
  core.hooksPath ...`, e.g. husky-style `.husky/_`) gets no scan and no
  warning at all.** Repo-local config wins over global, so our `pre-push`
  hook never runs there — not even to print the "gitleaks missing" warning.
  These are exactly the repos most likely to have hook tooling already, so
  don't assume "no warning" means "scanned"; check `git config --local
  --get core.hooksPath` if you're unsure — bare `--get` (no `--local`)
  returns the *effective* merged value, which shows the global value in
  every ordinary repo and would mask exactly this case.
- **A `core.hooksPath` pointing at a directory that no longer exists
  disables all hooks, silently.** If `~/.claude/dcltdw/githooks` is missing
  or stale (e.g. a primary clone checked out to a commit before
  `claude/githooks/` existed), git runs no hooks at all for that repo and
  prints nothing. Verify the path resolves (`ls
  "$(git config --global --get core.hooksPath)"`) if pushes seem
  unexpectedly unscanned.

**To revert:** `git config --global --unset core.hooksPath` undoes this —
git goes back to consulting each repo's own `.git/hooks/`. No other
rollback is needed; the `~/.claude/dcltdw` symlink and the skills-plugin
install from the same `install.sh` run are unaffected.

**Two delivery paths, and they behave differently — this is the single most
confusing thing about this setup.** `AGENTS.md` reaches a machine through the
`~/.claude/dcltdw` symlink: a `git pull` alone is enough, nothing to re-run.
`claude/skills/**` instead reaches a machine only through the plugin's
**cached copy**, keyed by the `version` field in
`claude/.claude-plugin/plugin.json`. Re-run `./install.sh` after pulling — it
calls `claude plugin update dcltdw@dcltdw`, which refreshes that cache, but
**only if `version` changed** in the pull you just took. Without a bump it
reports "already at the latest version" and the stale copy survives.
(`claude plugin marketplace update`, which install.sh also runs, refreshes
marketplace metadata only — never the plugin's cached content by itself.)

**Standing rule for every future change to `claude/skills/**`:** bump
`version` in `claude/.claude-plugin/plugin.json` in the same change, or
installed machines never see it. Edits to `AGENTS.md` or this file do **not**
need a bump — they ship live through the symlink, not the cache.

## Delivery paths

This directory ships through two complementary channels — neither replaces
the other:

- **The `~/.claude/dcltdw` symlink** (created by `install.sh`) carries
  everything that must be *live on pull*: the always-loaded `AGENTS.md`
  import and `githooks/`, which `core.hooksPath` points into.
- **The `dcltdw` plugin cache** delivers `skills/` — and only `skills/` —
  gated by `version` bumps in `.claude-plugin/plugin.json`. (The cached
  copy is actually a full snapshot of `claude/`, so files like
  `AGENTS.md` ride along in it too; those ride-alongs are inert, since
  the live `@`-import resolves through the symlink, not the cache.)

Plugin-only delivery is not currently possible (verified against Claude
Code 2.1.233, 2026-08): plugins cannot contribute always-loaded
instruction text, cannot serve per-repo conditional content or
version-stable import paths, and their cache path is version-stamped and
therefore unusable as a `core.hooksPath` target. **Revisit retiring the
symlink when Claude Code ships all three:** (1) always-loaded plugin
instruction text; (2) per-repo conditional plugin content or a
version-stable import path into an installed plugin; (3) a version-stable
path suitable for `core.hooksPath` (or plugin-managed git hooks). Any one
of them landing is worth a fresh look; all three are needed to retire the
symlink outright.

Those three gates are unchanged standing policy — but note that gate (2) no
longer has a live driver. It existed to cover per-repo opt-in imports, and
this repo's last one is gone: the Garmin release procedure is a plugin skill
now, so the symlink carries only `AGENTS.md` and `githooks/`. Whether losing
that driver should retire gate (2) is a decision to take deliberately, on its
own; it is not narrowed here as a side effect of moving one file. Until then,
read gate (2) as policy awaiting review, **not** as evidence that the symlink
still serves per-repo conditional content — it no longer does, and per "How
imports resolve" below it never reliably could.

## Per-repo wiring

**Board IDs are project-specific.** The universal rules say to track work on a
project board (Todo → In Progress → Done → Won't Do) but can't hold IDs. If a
repo uses a board, record its IDs in that repo's own `CLAUDE.md` — board URL/id,
the Status field id, the option ids, and the `gh api graphql` query to re-derive
them if they drift.

**Garmin repos.** The release procedure is a skill now, not an import — it
arrives with the `dcltdw` plugin, so there is nothing to `@import`. Add two
things to the repo's own `CLAUDE.md`:

1. A pointer line, so a session knows the skill exists and that this repo has
   specifics of its own:

       Store releases: use the `dcltdw:garmin-release` skill; project specifics in
       the release supplement below.

2. A **release supplement** section holding what the shared skill can't know —
   this repo's specifics:

   - the signing key's path, and how a session verifies it's the right key;
   - the target device list, and which device is the primary test device;
   - where the store copy (description, changelog, screenshots) lives;
   - release quirks — anything about this app's release that has surprised
     someone before.

If the repo previously pointed at another "master" conventions doc, remove that
pointer — the shared rules and skills are the single source of truth now.

## Delivering a repo's CLAUDE.md change

Per the universal rules: branch and open a PR for approval. (`~/.claude/CLAUDE.md`
is user config, not a repo — `install.sh` edits it directly.)

## How imports resolve — and when they silently don't

`@import`s resolve against the local filesystem — but *where the import
line lives* decides whether it loads. Imports in user-scope memory
(`~/.claude/CLAUDE.md`) resolve unconditionally; that is why the global
`@~/.claude/dcltdw/AGENTS.md` import works. An import in a
*project-level* CLAUDE.md whose path resolves outside that project's
working directory is an **external import**: Claude Code gates it behind
a one-time per-project approval dialog, and while unapproved (or
declined) it is silently inert — the session simply never sees the file.
That is why this repo's skills are delivered as a plugin instead of via
per-repo imports; do not add `@~/.claude/...` lines to project
CLAUDE.mds.
