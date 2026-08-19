# Classification Pin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the classification-pin section to `claude/AGENTS.md` so any diff touching the `claude/` tree is forced onto the architectural path (spec, then plan), closing dcltdw/agents#16.

**Architecture:** One new prose section in `claude/AGENTS.md`, inserted immediately after "Model handoffs at phase boundaries" (it protects that section's artifact anchor). No skill edits, no plugin version bump — enforcement is by instruction rank (AGENTS.md outranks skills). The rule text is normative in the spec; this plan copies it verbatim and verifies the copy mechanically.

**Tech Stack:** Markdown, git, `gh`. No test suite exists in this repo; verification is a text diff against the spec.

**Spec:** `docs/superpowers/specs/2026-08-19-classification-pin-design.md` (committed on this branch — read it first).

## Global Constraints

- Work ONLY in the worktree `/Users/dcltdw/Github/agents/.worktrees/docs-16-classification-pin`, branch `docs/16-classification-pin`. Never commit to `main`.
- NEVER run `install.sh` from this worktree — it repoints machine-global symlinks at the throwaway checkout and strands the machine's rule imports.
- The implementation diff must touch `claude/AGENTS.md` and nothing else (the spec and this plan are already committed on the branch).
- Stamp every commit with a `Co-Authored-By: <current AI model> <noreply@anthropic.com>` trailer.
- Confirm the branch with `git branch --show-current` before each commit.
- Open the PR and STOP — wait for approval; never merge unprompted.

---

### Task 1: Insert the classification-pin section into `claude/AGENTS.md`

**Files:**
- Modify: `claude/AGENTS.md` (insert between the end of "Model handoffs at phase boundaries", line 60, and "## Handing off to another model", line 62)

**Interfaces:**
- Consumes: the normative rule text in the spec's Decision 1 blockquote.
- Produces: a `## Classification pin: doctrine takes the architectural path` section that Task 2's PR ships. Later fleet behavior depends on this heading and rule text existing verbatim.

- [ ] **Step 1: Confirm the branch**

Run: `git branch --show-current`
Expected: `docs/16-classification-pin`

- [ ] **Step 2: Insert the section**

In `claude/AGENTS.md`, find this anchor (the last paragraph of "Model handoffs at phase boundaries" followed by the next section heading):

```markdown
**This outranks a skill's closing script.** `superpowers:writing-plans` ends by
offering "Inline Execution — execute tasks in this session"; that offer is a
boundary crossing and this rule refuses it. Put the execution style
(subagent-driven vs inline) *inside* the handoff prompt, for the next session
to act on.

## Handing off to another model
```

Replace it with (the new section inserted between the two, all other lines byte-identical):

```markdown
**This outranks a skill's closing script.** `superpowers:writing-plans` ends by
offering "Inline Execution — execute tasks in this session"; that offer is a
boundary crossing and this rule refuses it. Put the execution style
(subagent-driven vs inline) *inside* the handoff prompt, for the next session
to act on.

## Classification pin: doctrine takes the architectural path

The brainstorming skill has every session classify a task as spike /
bounded / architectural. One classification is not the session's to
make:

**Any diff touching the agents repo's `claude/` tree takes the
architectural path — spec, then plan — regardless of apparent size.**
"It's just a small doctrine edit" is not a classification argument; the
diff paths are the classification. Everything under `claude/` deploys
machine-globally — AGENTS.md, the skills, the pre-push hook, the plugin
manifest — so a mis-sized change there lands in every repo at once. And
a "bounded" label doesn't merely skip the spec: bounded means no plan
file is ever written, which deletes the artifact handoff event 1 is
anchored to. That is how a session slid from design approval straight
into implementation with no spec, no plan, and no handoff — the
artifact anchor was defeated upstream, at the arguable decision that
determines whether the artifact ever exists. A path can't be argued
with.

**One carve-out, granted only by dcltdw.** A genuinely mechanical
edit — a typo, a broken link — may take the bounded path only when
dcltdw explicitly grants that for the specific change, in response to
an ask. The grant is in the transcript or it isn't; the session never
self-classifies into the carve-out. Same shape as board discovery:
stop and ask.

## Handing off to another model
```

- [ ] **Step 3: Verify the inserted text matches the spec byte-for-byte**

The spec carries the rule as a `> `-prefixed blockquote; strip the prefix and diff it against the section now in the file (run from the worktree root; `$SCRATCH` is any scratch directory):

```bash
sed -n '/^> ## Classification pin/,/^> stop and ask\.$/p' \
  docs/superpowers/specs/2026-08-19-classification-pin-design.md \
  | sed -E 's/^> ?//' > "$SCRATCH/rule-spec.txt"
sed -n '/^## Classification pin/,/^stop and ask\.$/p' \
  claude/AGENTS.md > "$SCRATCH/rule-file.txt"
diff "$SCRATCH/rule-spec.txt" "$SCRATCH/rule-file.txt"
```

Expected: no output (exit 0). Any output means the copy drifted — fix the file, not the spec.

- [ ] **Step 4: Verify the diff touches only `claude/AGENTS.md`**

Run: `git status --porcelain`
Expected: exactly one line, ` M claude/AGENTS.md`.

Also confirm the anchor's neighbors survived: `grep -n '^## ' claude/AGENTS.md` must show `Classification pin: doctrine takes the architectural path` between `Model handoffs at phase boundaries` and `Handing off to another model`.

- [ ] **Step 5: Commit**

```bash
git add claude/AGENTS.md
git commit -m "Classification pin: any claude/ diff takes the architectural path (#16)

Co-Authored-By: <current AI model> <noreply@anthropic.com>"
```

### Task 2: Open the PR

**Files:**
- None modified — PR mechanics only.

**Interfaces:**
- Consumes: branch `docs/16-classification-pin` with the spec, this plan, and Task 1's commit.
- Produces: an open PR against `main` whose body's first line is `Closes #16`.

- [ ] **Step 1: Push the branch**

Run: `git push -u origin docs/16-classification-pin`

The global pre-push hook (gitleaks) scans outgoing commits. If it warns gitleaks is missing, manually scan the diff for secrets before pushing (there should be none — the diff is prose).

- [ ] **Step 2: Open the PR via the `dcltdw:opening-a-pr` skill**

Invoke `dcltdw:opening-a-pr` and follow it — it owns the body format (first line `Closes #16`), the changelog requirement, and the board-card move. Title suggestion, in the repo's style:

`Classification pin: doctrine diffs take the architectural path — a "bounded" label can no longer delete the plan-file anchor (#16)`

- [ ] **Step 3: Stop and wait for approval**

Do not merge. Report the PR URL and stop. (On merge, the `dcltdw:cleaning-up-after-pr-merge` skill takes over, in that later session.)
