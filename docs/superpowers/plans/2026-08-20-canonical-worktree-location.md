# Canonical Worktree Location Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Declare `~/Github/.worktrees/<repo>/<branch>` in AGENTS.md as the machine-wide canonical worktree location, dissolving the collision between `superpowers:using-git-worktrees` Step 1b and the no-commits-to-main rule (dcltdw/agents#21).

**Architecture:** One prose addition to AGENTS.md § "Concurrent agents" (rides the skill's documented directory-selection priority #1 — no skill fork), plus removal of this repo's now-dead `.gitignore` entry and empty local worktree dir. AGENTS.md ships live through the `~/.claude/dcltdw` symlink.

**Tech Stack:** Markdown doctrine, git, `gh`. No code, no tests — verification is walking the skill's decision procedure against the amended text.

**Spec:** `docs/superpowers/specs/2026-08-20-canonical-worktree-location-design.md`

## Global Constraints

- Work happens in the existing worktree `~/Github/.worktrees/agents/canonical-worktree-location`, branch `canonical-worktree-location` (already holds the spec commit `075fa21`). Confirm the branch before every commit.
- **Never run `install.sh` from this worktree** (AGENTS.md § "Concurrent agents": it would repoint `~/.claude/dcltdw` at a throwaway checkout). Nothing in this plan needs it.
- **No plugin version bump** — the diff touches `claude/AGENTS.md` and `.gitignore` only; per ADOPTING.md, bumps are for `claude/skills/**` only. Do not edit `claude/.claude-plugin/plugin.json`.
- **No `install.sh` change** — no machine state is mutated; `git worktree add` creates parent directories itself.
- This repo has no `CHANGELOG.md`, so the `dcltdw:opening-a-pr` changelog requirement does not fire.
- Stamp each commit with a `Co-Authored-By: Claude <requested-model> <noreply@anthropic.com>` trailer naming the model the executing session requested.

---

### Task 1: AGENTS.md — the canonical-location rule

**Files:**
- Modify: `claude/AGENTS.md` (insert after the "working tree is shared state" bullet, which ends at line 166: "…floor here, not the ceiling.")

**Interfaces:**
- Consumes: the approved rule semantics in the spec's "The rule text" section.
- Produces: the declared worktree directory preference that `superpowers:using-git-worktrees` priority #1 reads. Task 2's gitignore removal is justified by this text landing first.

- [ ] **Step 1: Insert the rule as a nested sub-bullet**

In `claude/AGENTS.md`, directly after the line `  floor here, not the ceiling.` (end of the "**The working tree is shared state.**" bullet, before the "**A worktree does not isolate the machine.**" bullet), insert:

```markdown
  - **Canonical worktree location: `~/Github/.worktrees/<repo>/<branch>`**
    — for every repo, regardless of where its clone lives. This is the
    declared directory preference `superpowers:using-git-worktrees` honors
    without asking (its git-fallback priority #1). The root is pinned to
    local, unsynced disk on purpose: a clone may live inside a file-sync
    service, and a worktree never should — sync churn on build artifacts
    and git metadata corrupts working state. Sitting outside every repo's
    tree, the location never triggers the skill's project-local safety
    verification: no `.gitignore` entry, no commit to `main`
    (dcltdw/agents#21). This governs the git-fallback path only — a native
    worktree tool (e.g. `EnterWorktree`) owns its own placement; keep
    preferring it. An existing project-local `.worktrees/` in a repo is
    outranked by this declaration: don't create new ones; let old ones
    drain via post-merge cleanup.
```

(Two-space indent for the sub-bullet marker, four-space continuation — match the file's existing nested-list style. Minor wording adjustments for flow are allowed; the semantics are pinned by the spec.)

- [ ] **Step 2: Verify against the skill's decision procedure**

Read the installed `superpowers:using-git-worktrees` SKILL.md (under `~/.claude/plugins/cache/claude-plugins-official/superpowers/*/skills/using-git-worktrees/` — take the newest version if several) § "Directory Selection" and § "Safety Verification" and confirm, against the text just inserted:

1. Priority #1 ("Check your instructions for a declared worktree directory preference … use it without asking") is satisfied by the new AGENTS.md text — it names a concrete directory, so priorities #2/#3 are never reached.
2. The declared path is outside any repo tree, so "Safety Verification (project-local directories only)" does not apply — the gitignore-and-commit instruction can no longer fire.
3. The sub-bullet's scope claim matches the skill: the preference lives in Step 1b (git fallback); Step 1a (native tools) is untouched.

Expected: all three hold by inspection. If any doesn't, the inserted text is wrong — fix it, don't reinterpret the skill.

- [ ] **Step 3: Render/consistency check**

Run: `grep -n "Canonical worktree location" claude/AGENTS.md`
Expected: exactly one hit, inside § "Concurrent agents", between the two hazard bullets' texts.

- [ ] **Step 4: Commit**

```bash
git branch --show-current   # must print: canonical-worktree-location
git add claude/AGENTS.md
git commit -m "AGENTS.md: canonical worktree location — fixed root outside every repo tree (#21)"
```

(Append the Co-Authored-By trailer per Global Constraints.)

---

### Task 2: Tidy this repo's worktree residue

**Files:**
- Modify: `.gitignore` (repo root — remove the `.worktrees/` line)
- Working-tree only: delete the empty untracked `.worktrees/` directory in the **primary clone** `/Users/dcltdw/Github/agents`

**Interfaces:**
- Consumes: Task 1's rule (the reason the entry is dead: worktrees no longer live project-local).
- Produces: nothing later tasks rely on.

- [ ] **Step 1: Remove the gitignore line**

In `.gitignore` (currently three lines: `.DS_Store`, `.superpowers/`, `.worktrees/`), delete the `.worktrees/` line, leaving:

```
.DS_Store
.superpowers/
```

- [ ] **Step 2: Verify nothing newly untracked appears**

Run: `git status --short`
Expected: only the staged/modified `.gitignore` — no `.worktrees/` entry appears (the primary clone's copy is empty, and this worktree has none). If a `.worktrees/` path shows up untracked, stop: something is inside it — investigate before committing.

- [ ] **Step 3: Commit**

```bash
git branch --show-current   # must print: canonical-worktree-location
git add .gitignore
git commit -m "gitignore: drop .worktrees/ — worktrees are canonical outside the repo tree (#21)"
```

(Append the Co-Authored-By trailer per Global Constraints.)

- [ ] **Step 4: Remove the empty directory from the primary clone**

This is a deliberate, named mutation of shared state (the primary clone's working tree), allowed because it's this task's own repo and the directory is empty and untracked:

```bash
rmdir /Users/dcltdw/Github/agents/.worktrees
```

Expected: succeeds silently. `rmdir` (not `rm -rf`) on purpose — it fails if the directory is unexpectedly non-empty; if it does fail, investigate rather than force.

---

### Task 3: Push and open the PR

**Files:** none (process task)

**Interfaces:**
- Consumes: commits from Tasks 1–2 plus the spec/plan commits already on the branch.
- Produces: the PR closing #21.

- [ ] **Step 1: Push the branch**

```bash
git push -u origin canonical-worktree-location
```

The global pre-push gitleaks hook scans outgoing commits; if it warns gitleaks is missing, scan the diff manually for secrets before pushing (there should be none — the diff is prose).

- [ ] **Step 2: Open the PR via the skill**

REQUIRED SUB-SKILL: `dcltdw:opening-a-pr`. The body must contain `Closes #21`. Substance for the body: the collision (skill Step 1b's gitignore-commit vs. no-commits-to-main), the resolution (fixed canonical location outside every repo tree, riding the skill's priority #1), the Dropbox rationale for a fixed rather than clone-derived root, and the tidy-up. Point reviewers at the spec and plan files in the diff.

- [ ] **Step 3: Stop — do not merge**

Per AGENTS.md § "Branches and PRs": wait for approval. Board card #21 is already In Progress; the merge-time flow (`dcltdw:cleaning-up-after-pr-merge`) handles Done.
