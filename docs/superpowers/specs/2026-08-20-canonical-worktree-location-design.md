# Canonical worktree location — design

**Date:** 2026-08-20
**Ticket:** dcltdw/agents#21 — "Worktree setup collides with the no-commits-to-main rule: decide a canonical worktree location"
**Status:** approved design, pre-implementation

## Problem

Two rules contradict each other the first time any repo uses a worktree.
`superpowers:using-git-worktrees` Step 1b requires a project-local worktree
directory to be gitignored, and prescribes: "Add to .gitignore, commit the
change, then proceed." At that point no feature branch exists yet, so the
commit lands on whatever is checked out — normally `main` — which AGENTS.md
§ "Branches and PRs" forbids. Branching first doesn't escape: the
`.gitignore` change then rides inside an unrelated PR and widens its scope.
The collision fires in every repo that hasn't yet done worktree work, so it
is cross-project.

## Decision

**AGENTS.md declares a canonical worktree location outside every repo's
tree — the fixed path `~/Github/.worktrees/<repo>/<branch>` — via the
skill's own directory-selection priority #1** ("check your instructions for
a declared worktree directory preference … use it without asking").

Why this resolves the collision rather than working around it: the skill
scopes its safety verification to "project-local directories only." A
worktree outside the repo tree never triggers the gitignore-and-commit
step, so the forbidden commit is structurally impossible. No skill fork;
the declaration rides a documented extension point.

The path is **fixed, not derived from the clone's location**, on purpose:
five repos live inside Dropbox, and worktrees must never land in a file-sync
service — sync churn on build artifacts and git metadata corrupts working
state. Pinning the root to local, unsynced disk is the simplest rule that
guarantees this. It also matches the stopgap already practiced twice
(recorded in #21).

## Rejected alternatives

- **Per-repo gitignore PR** (ticket candidate 2): honest, but a
  PR-per-repo tax forever, requires remembering it *before* the skill
  fires, blocks the actual task on review latency — and keeps worktrees
  inside the repo tree, which is the precondition, not a fix for it.
- **Machine-global `core.excludesFile`** (ticket candidate 3): no repo
  commits, but mutates shared machine state (the category § "Concurrent
  agents" flags for verify-and-restore care), forces `install.sh` to own
  merging with any pre-existing excludesFile, and is invisible from inside
  a repo. Also still keeps worktrees project-local.
- **Parent-derived path** (`<parent-of-clone>/.worktrees/<repo>/<branch>`):
  clone-location independent and identical to the fixed path for `~/Github`
  clones, but it follows a Dropbox-resident clone *into* Dropbox — exactly
  the placement the fixed root exists to prevent.

## The rule text

Added to AGENTS.md § "Concurrent agents", as a sub-point of the "working
tree is shared state" bullet (that bullet already points sessions at the
skill, and is therefore the "instructions" the skill's priority #1 reads):

> **Canonical worktree location: `~/Github/.worktrees/<repo>/<branch>`** —
> for every repo, regardless of where its clone lives; `<repo>` is the
> clone directory's basename. This is the declared directory preference
> `superpowers:using-git-worktrees` honors without asking (its
> git-fallback priority #1). The root must sit on local, unsynced disk: a
> clone may live inside a file-sync service, and a worktree never should —
> sync churn on build artifacts and git metadata corrupts working state.
> On a machine where `~/Github` is itself inside a sync service, pick a
> local root there instead. Sitting outside every repo's tree, the
> location never triggers the skill's project-local safety verification:
> no `.gitignore` entry, no commit to `main` (dcltdw/agents#21). This
> governs the git-fallback path only — a native worktree tool (e.g.
> `EnterWorktree`) owns its own placement; keep preferring it. An existing
> project-local `.worktrees/` in a repo is outranked by this declaration:
> don't create new ones; `superpowers:finishing-a-development-branch`
> drains old ones, removing each merged worktree but not the empty parent
> directory or a repo's gitignore line.

(The plan may adjust wording for flow within the section; the semantics
above are the approved content.)

## What ships, and what doesn't change

- The AGENTS.md edit ships live through the `~/.claude/dcltdw` symlink on
  pull. **No `install.sh` change** — no machine state is mutated, and
  `git worktree add` creates parent directories itself, so nothing needs
  pre-creating. **No plugin version bump** — per ADOPTING.md, bumps are for
  `claude/skills/**` only.
- **No skill fork.** The declaration uses the skill's documented
  directory-selection priority #1.
- **No migration for other repos.** A sweep of `~/Github` found exactly one
  repo with residue from the collision: this one.

## Tidy-up riding in the same PR

- Remove the now-dead `.worktrees/` line from this repo's `.gitignore`.
- Delete the empty untracked `.worktrees/` directory from the primary
  clone's working tree (working-tree removal only; empty directories are
  never tracked).

## Edge cases

- **Slashed branch names** (`feature/foo`) nest naturally under `<repo>/`.
- **Basename collision:** two repos sharing a basename in different parents
  (a `~/Github/foo` and a Dropbox `foo`) share `~/Github/.worktrees/foo/`;
  an actual clash requires the same branch name in both. No instance on
  this machine today — every clone basename is distinct (the apparent
  `Dropbox/Github/mystical_ps/dmmlib` is a symlink to
  `Dropbox/Github/dmmlib`, the same clone). Noted and accepted, not
  engineered around.
- **Machines without `~/Github`:** `git worktree add` creates the full
  parent chain, so the path works on first use.
- **Non-goal — nested repos:** if a clone's parent directory is itself
  inside some outer git repo, a sibling `.worktrees` would be project-local
  to that outer repo. This rule does not try to solve nested-repo layouts.

## Verification

Doctrine has no test suite. Verification is walking
`superpowers:using-git-worktrees`' decision procedure as written against
the amended AGENTS.md, in a repo whose `.gitignore` has no worktree entry,
and confirming it terminates at the declared path with zero commits
required — that by-inspection walk is the verification of the rule. The
worktree used to build this change sits at
`~/Github/.worktrees/agents/canonical-worktree-location`, but it was
created as the ad-hoc stopgap *before* the rule existed: it evidences that
the path dodges safety verification, not that the amended AGENTS.md text
drives a session there.

The PR closes #21.
