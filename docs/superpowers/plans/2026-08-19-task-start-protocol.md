# Task-Start Protocol Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the task-start protocol (issue per task, board discovery, canonical board schema, PR–issue linking) to AGENTS.md, and make `dcltdw:opening-a-pr` enforce the `Closes #N` line.

**Architecture:** Two doctrine files change — `claude/AGENTS.md` gains a "Starting a task" section and a canonical-schema bullet in "Project board"; `claude/skills/opening-a-pr/SKILL.md` gains the issue check and the body-first-line rule, with the plugin version bumped 0.3.0 → 0.4.0. No code, no new tooling.

**Tech Stack:** Markdown, `gh` CLI (verification only).

**Spec:** `docs/superpowers/specs/2026-08-19-task-start-protocol-design.md`

## Global Constraints

- Work happens in the existing worktree `/Users/dcltdw/Github/agents/.worktrees/task-start-protocol`, branch `task-start-protocol` (already holds the spec and a `.gitignore` commit). Never commit to `main`.
- Confirm the branch before every commit: `git branch --show-current` → `task-start-protocol`.
- Every commit carries a `Co-Authored-By:` trailer naming the current AI model.
- Never run `install.sh` from the worktree (it repoints `~/.claude/dcltdw` machine-globally; see AGENTS.md "Concurrent agents").
- This repo has no test suite; each task's verification is the exact read-back or command given in its steps.
- The tracked issue is dcltdw/agents#13; the board is Agent tooling (project 8, owner dcltdw). #13's card item id: `PVTI_lAHOAAdfes4BgolJzg3J9yo`; project id `PVT_kwHOAAdfes4BgolJ`; Status field id `PVTSSF_lAHOAAdfes4BgolJzhfnY94`; option ids: In Progress `44811c68`, Done `702fcf43`.

---

### Task 1: "Starting a task" section and canonical schema in AGENTS.md

**Files:**
- Modify: `claude/AGENTS.md` (insert new section between "Concurrent agents" and "Branches and PRs"; rewrite the "Project board" section)

**Interfaces:**
- Consumes: nothing.
- Produces: the section anchor `#project-board` and the rule text that Task 2's skill edit refers to ("the Starting a task rule").

- [ ] **Step 1: Move the board card to In Progress** (work on #13 is now underway; the opening-a-pr skill expects the move to have happened by PR time)

```bash
gh project item-edit --id PVTI_lAHOAAdfes4BgolJzg3J9yo --project-id PVT_kwHOAAdfes4BgolJ --field-id PVTSSF_lAHOAAdfes4BgolJzhfnY94 --single-select-option-id 44811c68
```

- [ ] **Step 2: Insert the new section.** In `claude/AGENTS.md`, immediately before the line `## Branches and PRs`, insert exactly:

```markdown
## Starting a task
Before creating the work branch, the task must have an issue, and the issue
must be on the repo's board. In order:

1. **No issue covering this task? Create one** — sized to one reviewable PR
   (see Branches and PRs).
2. **Find the board via the repo's linked projects** (`gh repo view
   <owner>/<repo> --json projectsV2`). No linked board, or more than one
   plausible candidate? **Stop and ask** — the answer may be "create one,"
   or that an existing board is correct. Never create a board unprompted.
3. **Creating a board (only after approval):** use the canonical schema in
   [Project board](#project-board), and link the new project to the repo so
   the next agent can discover it mechanically.
4. **The PR references the issue** — `Closes #N`, or `Refs #N` when the PR
   does not finish the issue (the `dcltdw:opening-a-pr` skill enforces
   this).

Branch creation is the anchor on purpose: it is checkable, and it exempts
sessions that never produce a branch — a question answered, a spike
reported.

```

- [ ] **Step 3: Rewrite the "Project board" section.** Replace the current section body (the three bullets under `## Project board`, currently lines 119–124) with exactly:

```markdown
## Project board
- Track work on the project board (the PR skills say when to move cards).
- **Canonical board schema** — the shape for any newly created board, and
  the target when bringing an old one in line:
  - **Status**: `Todo` / `In Progress` / `Done` / `Won't Do` — nothing
    else. Review state lives on the PR, not in a column.
  - **Labels**: GitHub's nine defaults plus `deferred` ("Real work,
    deliberately parked — revisit when the need is live (not wontfix)").
  - Repo-specific domain labels and priority schemes are repo-local —
    fine to have, never canonical.
- Two terminal states: **Done** (work happened) and **Won't Do** (reviewed
  and deliberately closed without action — always record a one-line
  reason). A board missing **Won't Do** gets it added — it is part of the
  canonical schema.
- Say **refinement** or **triage** for backlog work — never "grooming"
  (outdated).
```

- [ ] **Step 4: Verify the edit.** Run:

```bash
grep -n "^## " /Users/dcltdw/Github/agents/.worktrees/task-start-protocol/claude/AGENTS.md
```

Expected: `## Starting a task` appears between `## Concurrent agents` and `## Branches and PRs`; exactly one `## Project board` heading; no duplicated sections. Then read the two edited sections in full and confirm they match the text above verbatim.

- [ ] **Step 5: Commit**

```bash
git -C /Users/dcltdw/Github/agents/.worktrees/task-start-protocol branch --show-current
git -C /Users/dcltdw/Github/agents/.worktrees/task-start-protocol add claude/AGENTS.md
git -C /Users/dcltdw/Github/agents/.worktrees/task-start-protocol commit -m "feat: task-start protocol — issue per task, board discovery, canonical schema (#13)

Co-Authored-By: <current model> <noreply@anthropic.com>"
```

### Task 2: `opening-a-pr` enforces the issue link; plugin bump

**Files:**
- Modify: `claude/skills/opening-a-pr/SKILL.md`
- Modify: `claude/.claude-plugin/plugin.json` (version only)

**Interfaces:**
- Consumes: the "Starting a task" rule name from Task 1.
- Produces: nothing later tasks rely on.

- [ ] **Step 1: Edit the "Before opening" list.** In `claude/skills/opening-a-pr/SKILL.md`, replace item 2 (`2. Move the board card **Todo → In Progress** (if the repo has a board).`) with exactly:

```markdown
2. Confirm the task's issue exists — the Starting-a-task rule (AGENTS.md)
   created it before the branch; if it somehow doesn't, create it now.
   Move its board card **Todo → In Progress** (if the repo has a board).
```

- [ ] **Step 2: Add the body-first-line rule.** In the same file, in the `## PR body — five required sections, every time` section, insert immediately after the line `time pressure this is what gets dropped first:` a new first list item, so the list begins:

```markdown
- **First line, above everything:** `Closes #N` — or `Refs #N` when the PR
  does not finish the issue. First-line placement is checkable at a glance
  and keeps GitHub's auto-close linking working.
```

(The existing five bullets — Files changed, Work breakdown, Test expectations, Operational impact, Provenance — stay unchanged below it.)

- [ ] **Step 3: Bump the plugin version.** In `claude/.claude-plugin/plugin.json`, change `"version": "0.3.0"` to `"version": "0.4.0"`.

- [ ] **Step 4: Verify.** Run:

```bash
grep -n "Closes #N\|Starting-a-task\|0.4.0" /Users/dcltdw/Github/agents/.worktrees/task-start-protocol/claude/skills/opening-a-pr/SKILL.md /Users/dcltdw/Github/agents/.worktrees/task-start-protocol/claude/.claude-plugin/plugin.json
```

Expected: the SKILL.md hits for both the first-line rule and the issue-confirm step; plugin.json shows `0.4.0`. Read both edited hunks in full to confirm verbatim match.

- [ ] **Step 5: Commit**

```bash
git -C /Users/dcltdw/Github/agents/.worktrees/task-start-protocol branch --show-current
git -C /Users/dcltdw/Github/agents/.worktrees/task-start-protocol add claude/skills/opening-a-pr/SKILL.md claude/.claude-plugin/plugin.json
git -C /Users/dcltdw/Github/agents/.worktrees/task-start-protocol commit -m "feat: opening-a-pr enforces Closes #N first line; plugin 0.4.0 (#13)

Co-Authored-By: <current model> <noreply@anthropic.com>"
```

### Task 3: End-to-end verification, push, PR

**Files:**
- None created or modified (verification and delivery only).

**Interfaces:**
- Consumes: everything above.
- Produces: the open PR closing #13.

- [ ] **Step 1: Re-verify the discovery query against both branches of the rule** (verified 2026-08-19 during design; re-run — a check carried over from earlier prose is not verified):

```bash
gh repo view dcltdw/agents --json projectsV2
gh api graphql -f query='query{repository(owner:"dcltdw",name:"scripts"){projectsV2(first:10){nodes{number title}}}}' --jq '.data.repository.projectsV2.nodes'
```

Expected: agents returns the Agent tooling project; scripts returns `[]` (the stop-and-ask branch).

- [ ] **Step 2: Read the full rendered AGENTS.md top to bottom once** — checking the new section against the spec's Decision 1 and the Project board section against Decision 2, and that no other section contradicts them (in particular, "Branches and PRs" and the two PR skills' mentions of cards still read coherently).

- [ ] **Step 3: Scan the outgoing diff for secrets** (docs-only branch, but the rule is unconditional), then push:

```bash
git -C /Users/dcltdw/Github/agents/.worktrees/task-start-protocol diff main..task-start-protocol
git -C /Users/dcltdw/Github/agents/.worktrees/task-start-protocol push -u origin task-start-protocol
```

- [ ] **Step 4: Open the PR — REQUIRED SUB-SKILL: `dcltdw:opening-a-pr`.** Invoke the skill and follow it exactly. Constraints the skill will ask for: base `main`; body's **first line** is `Closes #13` (dogfooding Task 2's rule); five required sections including Provenance (`Agent:` and `Model / version:` per the executing session); no changelog entry (this repo keeps no `CHANGELOG.md` — state the omission in the body). Do not merge — wait for approval per AGENTS.md.

- [ ] **Step 5: Report.** Present the PR per the skill, note that #14 (board/label sync) unblocks once this merges, and stop. The #13 card moves to Done only at merge time, via `dcltdw:cleaning-up-after-pr-merge`; at that same moment, after the primary clone pulls, run `./install.sh --check` **from the primary clone** (never the worktree) to confirm the 0.4.0 plugin is picked up.
