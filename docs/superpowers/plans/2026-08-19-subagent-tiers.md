# SDD Subagent Tiers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. For this plan specifically, the handoff recommends **inline execution** (superpowers:executing-plans) — it is a single prose section in one file.

**Goal:** Add the "Subagent tiers in subagent-driven development" section to `claude/AGENTS.md`, plus a one-line cross-reference after the phase table, exactly as the approved spec's blockquotes prescribe.

**Architecture:** Two insertions into one Markdown doctrine file. The spec's two blockquotes are normative; the implementation copies them verbatim (byte-for-byte after stripping the `> ` blockquote prefix), enforced by a mechanical diff-check in each task. No code, no tests — verification is the diff-check plus an anchor-link check.

**Tech Stack:** Markdown, git, `awk`/`sed`/`diff` (BSD variants — this runs on macOS), `gh`.

**Spec:** `docs/superpowers/specs/2026-08-19-subagent-tiers-design.md` (approved in-chat by dcltdw 2026-08-19). Read it before starting — the plan argues from it.

## Global Constraints

- Work in the existing worktree `/Users/dcltdw/Github/agents/.worktrees/docs-10-subagent-tiers` on branch `docs/10-subagent-tiers`. Never commit to `main`. Run `git branch --show-current` before every commit.
- **NEVER run `./install.sh` from this worktree.** It repoints the machine-global `~/.claude/dcltdw` symlink at the throwaway checkout and strands the machine's rule imports.
- The content diff is `claude/AGENTS.md` only (this plan file's checkboxes may also be updated). Anything else appearing in `git status` is a mistake — stop and investigate.
- Stamp every commit with a `Co-Authored-By:` trailer naming the model the transcript asked for (the handoff requests Opus → `Co-Authored-By: Claude Opus <noreply@anthropic.com>`). You cannot observe which model you are running as; record the request, not a claim of fact.
- The spec's blockquote text is normative. If a diff-check fails, fix `claude/AGENTS.md` to match the spec — never the reverse.
- Open the PR with the `dcltdw:opening-a-pr` skill and wait for approval; do not merge.

---

### Task 1: Insert the new section into claude/AGENTS.md

**Files:**
- Modify: `claude/AGENTS.md` (insert between the end of "Classification pin: doctrine takes the architectural path" and the "## Handing off to another model" heading)

**Interfaces:**
- Produces: the rendered heading `## Subagent tiers in subagent-driven development`, whose GitHub anchor `#subagent-tiers-in-subagent-driven-development` Task 2's cross-reference link targets.

- [ ] **Step 1: Confirm branch and clean tree**

```bash
cd /Users/dcltdw/Github/agents/.worktrees/docs-10-subagent-tiers
git branch --show-current   # expected: docs/10-subagent-tiers
git status --short          # expected: empty
```

- [ ] **Step 2: Insert the section**

In `claude/AGENTS.md`, find this exact text (the last line of the classification-pin section followed by the next heading):

```
stop and ask.

## Handing off to another model
```

Replace it with (the new section slots between them; every line below between the two existing anchors is copied verbatim from the spec's Decision 2 blockquote with the `> ` prefix stripped):

```
stop and ask.

## Subagent tiers in subagent-driven development

The phase table above maps *phases of a session* to models. Subagent-driven
development adds a second axis the table doesn't cover: within one
execution session, which tier each dispatched **seat** gets — implementer,
reviewer, re-reviewer. Two rules and a ceiling:

- **Implementers: judgement, no fixed tier.** The right tier tracks how
  specified the plan is. A plan carrying complete code and exact text is
  transcription plus testing — the cheaper tier handles it, and in the
  measured run it beat the plan when the plan was wrong. A plan written in
  prose needs more capability in the seat.
- **Reviewers: one tier above the implementer, as a standing rule.** Review
  is where undirected suspicion pays, and a reviewer working only from the
  controller's risk list inherits the controller's blind spots. When the
  implementer already sits at the top of the seat range, the rule
  saturates: the reviewer sits there too — never above the range — and the
  lost capability edge is recovered with independence instead: fresh
  context, and a brief that invites findings beyond the named risks.
- **The ceiling: no seat runs Fable.** "One tier above" stops at the top of
  the seat range. Fable is the design-phase model (see the table above); in
  an execution seat it buys depth neither seat uses, at a multiple of the
  cost. "Use the most capable model for review" is a misreading of this
  rule, not a stricter version of it.

The seat range, like the phase table, names models only as today's answer
*(mapping current as of 2026-08)*: **Sonnet** is the floor and the default
implementer tier; **Opus** is the top and the reviewer tier. Re-pin on
model releases.

A dispatch is a request, not an observation — the tier you ask for says
nothing about which model actually served the seat. Stamp commit trailers
with what was requested (the Commits rule's model trailer; provenance is
dcltdw/agents#18).

## Handing off to another model
```

- [ ] **Step 3: Mechanical diff-check against the spec**

The section in `claude/AGENTS.md` must match the spec's blockquote byte-for-byte after stripping the blockquote prefix:

```bash
cd /Users/dcltdw/Github/agents/.worktrees/docs-10-subagent-tiers
awk '/^> ## Subagent tiers in subagent-driven development$/,/^> dcltdw\/agents#18\)\.$/' \
  docs/superpowers/specs/2026-08-19-subagent-tiers-design.md | sed -E 's/^> ?//' > /tmp/spec-section.txt
awk '/^## Subagent tiers in subagent-driven development$/,/^dcltdw\/agents#18\)\.$/' \
  claude/AGENTS.md > /tmp/agentsmd-section.txt
diff /tmp/spec-section.txt /tmp/agentsmd-section.txt && echo SECTION-VERBATIM
```

Expected: no diff output, then `SECTION-VERBATIM`. If it fails, fix `claude/AGENTS.md` to match `/tmp/spec-section.txt` and re-run.

- [ ] **Step 4: Commit**

```bash
git branch --show-current   # docs/10-subagent-tiers
git add claude/AGENTS.md
git commit -m "AGENTS.md: subagent tiers for SDD — seat rules, dated pin, Fable ceiling (#10)

Co-Authored-By: Claude Opus <noreply@anthropic.com>"
```

(Adjust the trailer to whatever model the transcript actually asked for, per Global Constraints.)

---

### Task 2: Insert the cross-reference after the phase table

**Files:**
- Modify: `claude/AGENTS.md` (inside "Model handoffs at phase boundaries", directly after the phase table)

**Interfaces:**
- Consumes: the heading anchor `#subagent-tiers-in-subagent-driven-development` created in Task 1.

- [ ] **Step 1: Insert the line**

In `claude/AGENTS.md`, find this exact text (the phase table's last row and the paragraph that follows it):

```
| **Executing a plan**, implementation, and the verification that follows | **Opus** |

Three events end a turn.
```

Replace it with (the three inserted lines are copied verbatim from the spec's Decision 4 blockquote with the `> ` prefix stripped):

```
| **Executing a plan**, implementation, and the verification that follows | **Opus** |

Phases are one axis. Seats *within* a single execution phase — subagent
dispatches in subagent-driven development — are another; see
[Subagent tiers in subagent-driven development](#subagent-tiers-in-subagent-driven-development).

Three events end a turn.
```

- [ ] **Step 2: Mechanical diff-check against the spec**

```bash
cd /Users/dcltdw/Github/agents/.worktrees/docs-10-subagent-tiers
awk '/^> Phases are one axis/,/^> \[Subagent tiers/' \
  docs/superpowers/specs/2026-08-19-subagent-tiers-design.md | sed -E 's/^> ?//' > /tmp/spec-crossref.txt
grep -A2 '^Phases are one axis' claude/AGENTS.md > /tmp/agentsmd-crossref.txt
diff /tmp/spec-crossref.txt /tmp/agentsmd-crossref.txt && echo CROSSREF-VERBATIM
```

Expected: no diff output, then `CROSSREF-VERBATIM`.

- [ ] **Step 3: Anchor consistency check**

The link target must match GitHub's auto-generated slug for the Task 1 heading (lowercase, spaces → hyphens):

```bash
grep -c '^## Subagent tiers in subagent-driven development$' claude/AGENTS.md   # expected: 1
grep -c '(#subagent-tiers-in-subagent-driven-development)' claude/AGENTS.md    # expected: 1
```

Both greps must return 1.

- [ ] **Step 4: Commit**

```bash
git branch --show-current   # docs/10-subagent-tiers
git add claude/AGENTS.md
git commit -m "AGENTS.md: phase table cross-references the seat axis (#10)

Co-Authored-By: Claude Opus <noreply@anthropic.com>"
```

---

### Task 3: Verify the committed branch and open the PR

**Files:**
- No new edits (verification + PR only)

**Interfaces:**
- Consumes: the two commits from Tasks 1–2 on `docs/10-subagent-tiers`.

- [ ] **Step 1: Re-run both diff-checks against the committed state, not the working tree**

```bash
cd /Users/dcltdw/Github/agents/.worktrees/docs-10-subagent-tiers
git stash list   # expected: empty; nothing hidden
git show HEAD:claude/AGENTS.md | awk '/^## Subagent tiers in subagent-driven development$/,/^dcltdw\/agents#18\)\.$/' > /tmp/committed-section.txt
diff /tmp/spec-section.txt /tmp/committed-section.txt && echo COMMITTED-SECTION-OK
git show HEAD:claude/AGENTS.md | grep -A2 '^Phases are one axis' > /tmp/committed-crossref.txt
diff /tmp/spec-crossref.txt /tmp/committed-crossref.txt && echo COMMITTED-CROSSREF-OK
```

Expected: `COMMITTED-SECTION-OK` and `COMMITTED-CROSSREF-OK`. (If `/tmp/spec-*.txt` are gone, regenerate them with the awk/sed commands from Tasks 1–2.)

- [ ] **Step 2: Confirm the diff is scoped to the intended files**

```bash
git diff origin/main...HEAD --stat
```

Expected: `claude/AGENTS.md` plus the spec and this plan under `docs/superpowers/` — nothing else.

- [ ] **Step 3: Push**

```bash
git push
```

The global pre-push hook (gitleaks) scans the commits; if it reports gitleaks missing, scan the diff manually for secrets before pushing (there should be none — it is prose).

- [ ] **Step 4: Open the PR**

Invoke the `dcltdw:opening-a-pr` skill and follow it. Parameters this plan fixes: base `main`, head `docs/10-subagent-tiers`, the body references `Closes #10`, and the body notes the provenance follow-up is dcltdw/agents#18. Suggested title: `AGENTS.md: subagent tiers for SDD — reviewers a tier above, Fable ceiling (#10)`.

- [ ] **Step 5: Stop**

Wait for dcltdw's review. Do not merge. On merge (later, human-approved), the `dcltdw:cleaning-up-after-pr-merge` skill owns branch/worktree cleanup and the board move to Done.
