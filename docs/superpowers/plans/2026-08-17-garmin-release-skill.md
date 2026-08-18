# Garmin Release Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the non-functional project-level `@~/.claude/dcltdw/garmin-release.md` imports with a `dcltdw:garmin-release` plugin skill, TDD-verified, rolled out across `dcltdw/agents`, `Flightdeck`, and `Understated`.

**Architecture:** The release procedure moves from a symlink-delivered markdown file (whose project-level import never loads — external imports are approval-gated) into the `dcltdw` plugin's cache-delivered `skills/`, gated by a version bump to 0.3.0. Garmin repos keep their always-loaded per-repo supplements and gain a one-line pointer to the skill. The `~/.claude/dcltdw` symlink and `core.hooksPath` are untouched.

**Tech Stack:** bash, `gh` CLI, `claude` CLI (NOT on PATH — see Global Constraints), Claude Code plugin skills (SKILL.md + `.claude-plugin/plugin.json`).

**Spec:** `docs/superpowers/specs/2026-08-17-garmin-release-skill-design.md` — read it first; it argues every decision this plan executes, including why alternatives were rejected.

## Global Constraints

- **Work in the worktree `~/Github/agents-exec`, branch `garmin-release-skill-impl`.** The primary clone `~/Github/agents` is LIVE: the `~/.claude/dcltdw` symlink serves every Claude session on this machine from it, and the plugin marketplace reads it. Do not switch its branch; do not leave it dirty.
- **NEVER run `./install.sh` (bare) from the worktree.** It repoints the machine-global symlink and the plugin marketplace at whatever directory it runs from; run from `~/Github/agents-exec` it would strand the machine when the worktree is removed. It runs exactly once in this plan — Task 6, from the primary clone. `./install.sh --check` is read-only and safe from anywhere.
- **The `claude` CLI is not on PATH.** Resolve it as install.sh does:
  `BIN=$(ls -d ~/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude | sort -Vr | head -1)`
- **Iron Law (writing-skills):** no SKILL.md text drafted or written before Task 2's failing baseline is documented and committed. Task 3's adjustments happen only against failures Task 2 observed; do not add guidance for behaviors the baseline already passed.
- **Any change to `claude/skills/**` and the `version` bump in `claude/.claude-plugin/plugin.json` must land in the same PR** (they do — both are Task 3, shipped in PR A).
- **Never commit to `main` in any repo. Open PRs and STOP for user approval — never self-merge.** Confirm the branch before every commit (`git branch --show-current`).
- Stamp every commit `Co-Authored-By: Claude <model> <noreply@anthropic.com>` with the model the session's transcript directs.
- The gitleaks pre-push hook is armed machine-wide; a scan error fails closed.
- The PR-lifecycle skills may not be invocable in-session (known harness quirk). Follow their canonical copies manually: `claude/skills/opening-a-pr/SKILL.md` and `claude/skills/cleaning-up-after-pr-merge/SKILL.md` in the primary clone.
- Baseline/GREEN `claude -p` runs execute with normal machine auth (no clean room — the spec records why none is needed). Advisory-phrased prompts only; `-p` denies unapproved mutating tools by default, which is the desired behavior.
- Board/issue IDs used below:
  - agents: umbrella issue `dcltdw/agents#6` (board item `PVTI_lAHOAAdfes4BgolJzg25434`), project 8, id `PVT_kwHOAAdfes4BgolJ`, Status field `PVTSSF_lAHOAAdfes4BgolJzhfnY94`, options: Todo `eae12008`, In Progress `44811c68`, Done `702fcf43`.
  - Flightdeck: project 5, id `PVT_kwHOAAdfes4BbXAc`, Status field `PVTSSF_lAHOAAdfes4BbXAczhWIC1k`, options: Todo `f75ad846`, In Progress `47fc9ee4`, Done `98236657`.
  - Understated: project 3, id `PVT_kwHOAAdfes4BZh9C`, Status field `PVTSSF_lAHOAAdfes4BZh9CzhUf9Q8`, options: Todo `f75ad846`, In Progress `47fc9ee4`, Done `98236657`.

---

### Task 1: Tracking issues in Flightdeck and Understated

**Files:** none (GitHub issues + boards only).

**Interfaces:**
- Consumes: umbrella issue `dcltdw/agents#6` (already open, In Progress on board 8).
- Produces: `$FD_ISSUE` and `$US_ISSUE` issue URLs, referenced by Tasks 7 and 8 PR bodies (`Closes #<n>`).

- [ ] **Step 1: Create the Flightdeck issue**

```bash
gh issue create --repo dcltdw/Flightdeck \
  --title "CLAUDE.md: replace dead garmin-release import with dcltdw:garmin-release skill pointer" \
  --body "The \`@~/.claude/dcltdw/garmin-release.md\` line in this repo's CLAUDE.md has never loaded: project-level imports resolving outside the working directory are approval-gated external imports, silently inert when unapproved. The shared release process is moving into a \`dcltdw:garmin-release\` plugin skill; this repo's CLAUDE.md drops the dead import and gains a one-line skill pointer. The Flightdeck release supplement stays.

Umbrella issue with the full cause analysis and design: dcltdw/agents#6."
```

- [ ] **Step 2: Create the Understated issue** — same command with `--repo dcltdw/Understated` and "this watch face's CLAUDE.md" phrasing; body otherwise identical.

- [ ] **Step 3: Add both to their boards as Todo**

```bash
FD_ITEM=$(gh project item-add 5 --owner dcltdw --url "$FD_ISSUE" --format json --jq '.id')
gh project item-edit --id "$FD_ITEM" --project-id PVT_kwHOAAdfes4BbXAc \
  --field-id PVTSSF_lAHOAAdfes4BbXAczhWIC1k --single-select-option-id f75ad846
US_ITEM=$(gh project item-add 3 --owner dcltdw --url "$US_ISSUE" --format json --jq '.id')
gh project item-edit --id "$US_ITEM" --project-id PVT_kwHOAAdfes4BZh9C \
  --field-id PVTSSF_lAHOAAdfes4BZh9CzhUf9Q8 --single-select-option-id f75ad846
```

- [ ] **Step 4: Cross-link from the umbrella**

```bash
gh issue comment 6 --repo dcltdw/agents \
  --body "Per-repo rewiring issues: $FD_ISSUE (Flightdeck), $US_ISSUE (Understated). Their PRs merge only after the skill is live on installed machines (rollout order in the design doc)."
```

- [ ] **Step 5: Verify** — `gh issue view` each URL; both open, bodies reference `dcltdw/agents#6`. Record both URLs in the SDD ledger for Tasks 7/8.

### Task 2: RED baseline (before any skill text exists)

**Files:**
- Create: `.superpowers/sdd/2026-08-17-garmin-release-skill/baseline-raw/` (gitignored transcripts)
- Create: `docs/superpowers/baselines/2026-08-17-garmin-release-baseline.md` (committed, graded write-up)

**Interfaces:**
- Produces: per-criterion PASS/FAIL verdicts with verbatim quotes — the only authority Task 3 may adjust the skill against.

- [ ] **Step 1: Workspace + binary**

```bash
cd ~/Github/agents-exec && git branch --show-current   # must print garmin-release-skill-impl
mkdir -p .superpowers/sdd/2026-08-17-garmin-release-skill/baseline-raw
BIN=$(ls -d ~/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude | sort -Vr | head -1)
"$BIN" --version
```

- [ ] **Step 2: S-0, delivery recheck (Understated)** — expected: reports the process is NOT in context.

```bash
cd ~/Github/Understated && "$BIN" -p "Quote, verbatim, the shared Garmin store-release process that applies to this repo (the pre-release checklist and the numbered release steps). If it is not in your context, say exactly that, and list the memory files you do have." \
  > ~/Github/agents-exec/.superpowers/sdd/2026-08-17-garmin-release-skill/baseline-raw/S0-understated.txt
```

- [ ] **Step 3: S-A, behavioral baseline (Understated — the sharper one; no release automation)**

```bash
cd ~/Github/Understated && "$BIN" -p "I want to prepare release v1.4.0 of this watch face for the Connect IQ store. Lay out exactly what you would do, in order, with the specific commands you would run. Do NOT execute anything or change any files — this is a dry-run plan only. Be concrete." \
  > ~/Github/agents-exec/.superpowers/sdd/2026-08-17-garmin-release-skill/baseline-raw/SA-understated.txt
```

- [ ] **Step 4: S-B, behavioral baseline (Flightdeck — expect partial passes via `tools/release.sh` + supplement)** — same prompt with "release v2.3.0 of this data field", output to `SB-flightdeck.txt`.

- [ ] **Step 5: Grade both behavioral transcripts** against these criteria, PASS/FAIL each, with a verbatim supporting quote per verdict (dispatch the write-up to a fresh reader who did not run the scenarios, per the last initiative's pattern):

  1. Scope-diffs `main` against the last release tag before building.
  2. Verifies the signing key by RSA-modulus match against a published artifact (naming the key path is not enough).
  3. Builds the store package via `-e` export (all products, not one device).
  4. Re-verifies the *built* artifact's modulus, not just the intended key.
  5. Store copy: updates description ("What's new" + history move, 4000-char cap) and changelog/README.
  6. Secret-scans the diff and built artifacts.
  7. Tags `vX.Y.Z`.
  8. Hand-off framing: the human uploads; the release is unconfirmed until wild evidence (dashboard/reporter), not the green build.

  Also record what the control did WELL unprompted (compile-verify is the likely pass) — Task 3 must not add emphasis there.

- [ ] **Step 6: Write the graded baseline doc** at `docs/superpowers/baselines/2026-08-17-garmin-release-baseline.md`: methods (exact prompts, binary version, cwd per scenario), the S-0 delivery result, per-criterion verdict tables for S-A/S-B with quotes, and a "what the skill must teach / must not belabor" synthesis. Disclose confounds (e.g. repo supplements legitimately in context — that is the real deployment condition, not contamination).

- [ ] **Step 7: Commit**

```bash
cd ~/Github/agents-exec && git add docs/superpowers/baselines/2026-08-17-garmin-release-baseline.md && git commit
```

### Task 3: Skill (GREEN), file deletion, version 0.3.0

**Files:**
- Create: `claude/skills/garmin-release/SKILL.md`
- Delete: `claude/garmin-release.md`
- Modify: `claude/.claude-plugin/plugin.json` (version + description)
- Modify: `.claude-plugin/marketplace.json` (plugin description)

**Interfaces:**
- Consumes: Task 2's verdicts (the only license to deviate from the port below).
- Produces: skill name `garmin-release` (namespace `dcltdw:garmin-release`) — the exact string Tasks 4, 7, 8 reference.

- [ ] **Step 1: Write `claude/skills/garmin-release/SKILL.md`.** Starting draft — a port of `claude/garmin-release.md` (read it from the branch) minus its "Project supplement" section, with this frontmatter:

```markdown
---
name: garmin-release
description: Use when releasing a Garmin Connect IQ app or watch face — cutting a store release, building or signing the .iq store package, updating store copy, or tagging a release.
---

# Garmin Connect IQ store release

Shared release process for dcltdw's Garmin apps (watch faces / apps).
Project specifics (signing-key path, device list, store-copy location,
quirks) live in each repo's CLAUDE.md release supplement — read it
alongside this skill.

Don't cut a release unless asked. Uploading to the store is
outward-facing and done by the human, not by Claude.

[pre-release checklist steps 1–10, ported verbatim from
claude/garmin-release.md]
```

  Then adjust ONLY against Task 2 failures: strengthen steps the baselines failed (expected candidates: modulus verification, store-copy cap/history, hand-off framing); do not add new guidance, tables, or emphasis for criteria both baselines passed. The description stays trigger-only — no workflow summary.

- [ ] **Step 2: GREEN by injection** — re-run S-A and S-B prompts with the skill body prepended:

```bash
SKILL=$(cat ~/Github/agents-exec/claude/skills/garmin-release/SKILL.md)
cd ~/Github/Understated && "$BIN" -p "You have this skill loaded:
<skill>
$SKILL
</skill>
[same S-A prompt verbatim]" > .../green-SA-understated.txt
```

  (Same for Flightdeck.) Grade against Task 2's criteria table. Expected: previously-failed criteria now PASS. If any still fails, refactor the skill against that observed failure and re-run that scenario — no other edits.

- [ ] **Step 3: Delete the old file and bump the version**

```bash
cd ~/Github/agents-exec && git rm claude/garmin-release.md
```

  In `claude/.claude-plugin/plugin.json`: `"version": "0.2.0"` → `"0.3.0"`; `"description"` → `"Cross-project skills for dcltdw's repos: PR lifecycle and Garmin releases"`. Mirror the same description string in `.claude-plugin/marketplace.json`'s plugin entry.

- [ ] **Step 4: Verify manifests** — `"$BIN" plugin validate ~/Github/agents-exec --strict` (or `plugin validate` on the plugin dir if the CLI wants the plugin root; both manifests must pass).

- [ ] **Step 5: Commit** (SKILL.md + deletion + both manifests + GREEN note appended to the baseline doc, one commit).

### Task 4: agents-repo docs and install.sh retarget

**Files:**
- Modify: `claude/ADOPTING.md`
- Modify: `CLAUDE.md` (repo root)
- Modify: `install.sh` (closing hint only)

**Interfaces:** consumes the skill name `dcltdw:garmin-release`; produces the pointer-line wording Tasks 7/8 copy into repo CLAUDE.mds.

- [ ] **Step 1: `claude/ADOPTING.md` — five edits:**
  1. Intro paragraph: drop `garmin-release.md` from the canonical-files list; it becomes "…live in this directory: **`AGENTS.md`** … The PR-lifecycle and Garmin-release skills ship separately, via the `dcltdw` plugin (see Delivery paths)."
  2. "Two delivery paths" paragraph and the standing-rule paragraph: remove `garmin-release.md` from the symlink-delivered examples and the no-bump list (AGENTS.md and ADOPTING.md remain the examples).
  3. "Delivery paths" section, symlink bullet: now carries "the always-loaded `AGENTS.md` import and `githooks/`" — the per-repo opt-in imports clause goes away.
  4. "Per-repo wiring" → **Garmin repos** subsection, rewritten: no `@import`. Instruct instead: add to the repo's CLAUDE.md (a) the pointer line — *"Store releases: use the `dcltdw:garmin-release` skill; project specifics in the release supplement below."* — and (b) a release-supplement section covering: signing-key path + how it's verified, target device list / primary test device, where the store copy lives, release quirks (this guidance absorbed from the deleted file's "Project supplement" section).
  5. "How resolution works" section, rewritten to record the gate (so the lesson is not relearned):

```markdown
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
```

- [ ] **Step 2: repo-root `CLAUDE.md`** — the symlink-delivered bullet drops `claude/garmin-release.md`: "- `claude/AGENTS.md` reaches an installed machine live, through the symlink — a `git pull` alone is enough."

- [ ] **Step 3: `install.sh` closing hint** (currently the `echo "Garmin repos: add '@~/.claude/dcltdw/garmin-release.md'…"` line) →

```bash
echo "Garmin repos: add the release supplement + dcltdw:garmin-release skill pointer to that repo's CLAUDE.md (see claude/ADOPTING.md)."
```

- [ ] **Step 4: Verify** — `bash -n install.sh`; `grep -rn 'garmin-release\.md' claude/ CLAUDE.md install.sh` returns only historical docs/ hits (i.e. none in live files); `./install.sh --check` from the worktree still passes (read-only).

- [ ] **Step 5: Commit.**

### Task 5: Whole-branch review + PR A — STOP at the merge gate

**Files:** none new (review may trigger one fix wave).

- [ ] **Step 1: Whole-branch review** (`origin/main...garmin-release-skill-impl`): spec-coverage check against the design doc; no orphaned references to `claude/garmin-release.md` in live files; Iron Law audit (baseline commit predates skill commit); version bump present and in the same PR as the skill. One fix wave maximum, per the SDD skill.
- [ ] **Step 2: Push** (gitleaks scans; branch includes plan + baseline + skill + docs commits).
- [ ] **Step 3: Open PR A** per `claude/skills/opening-a-pr/SKILL.md` (followed manually if not invocable): base `main`, five body sections, "Part of dcltdw/agents#6" (NOT `Closes` — the umbrella stays open through rollout). Operational impact section must state: after merge, installed machines need `git pull` + `./install.sh` **from the primary clone** to receive 0.3.0.
- [ ] **Step 4: STOP.** Report the PR URL and wait for the user to merge. Do not start Task 6.

### Task 6: Rollout on this machine (after the user merges PR A)

**Files:** none in-repo (machine state + verification evidence).

- [ ] **Step 1: Post-merge cleanup** per `claude/skills/cleaning-up-after-pr-merge/SKILL.md`: pull the **primary clone** (`git -C ~/Github/agents pull`); grep `main` for `claude/skills/garmin-release/SKILL.md` present and `claude/garmin-release.md` absent; `git -C ~/Github/agents-exec fetch --prune`; branch auto-delete is ON — verify with `git ls-remote --heads origin`, then delete the local branch (switch the worktree to a fresh `main`-tracking state first, or remove it in Task 9).
- [ ] **Step 2: Install the update — from the primary clone ONLY**

```bash
cd ~/Github/agents && ./install.sh
ls ~/.claude/plugins/cache/dcltdw/dcltdw/0.3.0/skills/   # expect garmin-release, opening-a-pr, cleaning-up-after-pr-merge
./install.sh --check                                      # expect: check passed
```

- [ ] **Step 3: Live trigger check** (the deferred real-world GREEN):

```bash
cd ~/Github/Understated && "$BIN" -p "I want to prepare the next store release of this watch face. Lay out exactly what you would do — do not execute anything."
```

  Expected: the transcript announces using `dcltdw:garmin-release` (or reproduces its steps with attribution to the skill). If the skill does not fire: verify the cache (Step 2) before touching skill wording; a delivery failure is not a description failure.
- [ ] **Step 4: Record** — comment the verification results (cache version, trigger-check outcome) on `dcltdw/agents#6`.

### Task 7: Flightdeck rewire — PR B

**Files:**
- Modify: `~/Github/Flightdeck/CLAUDE.md` (via a worktree of that repo, e.g. `git -C ~/Github/Flightdeck worktree add ~/Github/Flightdeck-exec -b claude-md-release-skill`)

- [ ] **Step 1: Move the Flightdeck issue's card Todo → In Progress** (ids in Global Constraints).
- [ ] **Step 2: Edit CLAUDE.md** — replace exactly this text:

```markdown
The Garmin store-release process is shared (edit the shared doc, not a copy):

@~/.claude/dcltdw/garmin-release.md
```

  with:

```markdown
Store releases: use the `dcltdw:garmin-release` skill; project specifics in
the release supplement below.
```

  The "### Flightdeck release supplement" section and everything else stays byte-identical.
- [ ] **Step 3: Verify** — `grep -c 'garmin-release.md' CLAUDE.md` → 0; `grep -c 'dcltdw:garmin-release' CLAUDE.md` → 1; diff shows only this hunk.
- [ ] **Step 4: Commit, push, open PR B** (five sections; `Closes #<FD_ISSUE>`; Operational impact: none — docs-only, takes effect next session). **STOP for the user to merge.**
- [ ] **Step 5: After merge:** cleanup per the skill (pull, content-grep, prune, remove the Flightdeck worktree), move the card → Done.

### Task 8: Understated rewire — PR C

Same shape as Task 7 against `~/Github/Understated` (worktree `~/Github/Understated-exec`, branch `claude-md-release-skill`), replacing exactly:

```markdown
The Garmin store-release process is shared (edit the shared doc, not a copy):

@~/.claude/dcltdw/garmin-release.md
```

with:

```markdown
Store releases: use the `dcltdw:garmin-release` skill; project specifics in
the release supplement below.
```

("### Understated release supplement" and all else byte-identical.) Board: Understated ids from Global Constraints. **STOP at the PR C merge gate**; after merge: cleanup, card → Done.

### Task 9: Close-out

- [ ] **Step 1: End-state sweep** — `grep -l '@~/.claude/dcltdw/garmin-release' ~/Github/*/CLAUDE.md` (and the Dropbox Understated path if still present) returns nothing; `./install.sh --check` passes; cache at 0.3.0.
- [ ] **Step 2: Close the umbrella** — comment on `dcltdw/agents#6` summarizing: cause, skill live at 0.3.0, both repos rewired, trigger check result; close the issue; move its card (item `PVTI_lAHOAAdfes4BgolJzg25434`) → Done (option `702fcf43`).
- [ ] **Step 3: Workspace cleanup** — `git -C ~/Github/agents worktree remove ~/Github/agents-exec` (after confirming nothing uncommitted), same for the Flightdeck/Understated worktrees; delete merged local branches per the cleanup skill (server truth first). The SDD ledger directory may be deleted once all tasks are complete, per the SDD skill's normal ending.
