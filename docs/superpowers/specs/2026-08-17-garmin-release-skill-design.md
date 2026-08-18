# Garmin release skill — design

Date: 2026-08-17. Approved in-chat (brainstorming session). Follows the
2026-08-15 PR-skills-plugin initiative (concluded at plugin 0.2.0) and the
migration of this tooling to `dcltdw/agents`.

## Problem (Finding 1) and its established cause

**Behavior:** the project-level imports `@~/.claude/dcltdw/garmin-release.md`
in `~/Github/Flightdeck/CLAUDE.md` and `~/Github/Understated/CLAUDE.md` never
expand. Two fresh sessions independently confirmed only three files in
context (global CLAUDE.md, AGENTS.md, the repo's own CLAUDE.md); asked to
quote the release steps, a session correctly answered "not in context". The
import lines are byte-identical in form to the working global one; the target
exists and is readable.

**Cause — by design, not a bug.** Per the Claude Code memory documentation
(code.claude.com/docs/en/memory, "Import additional files"): an import in a
*project-level* memory file whose path resolves **outside the working
directory** is an "external import". External imports are gated behind a
one-time per-project approval dialog; unapproved or declined, they stay
silently disabled and the dialog does not reappear. Imports in *user-scope*
files (`~/.claude/CLAUDE.md`) are exempt — which is exactly why the global
`@~/.claude/dcltdw/AGENTS.md` import works while the identically-formed
project-level line does not.

**Verified locally (2026-08-17):** every project entry in `~/.claude.json` on
this machine has `hasClaudeMdExternalIncludesApproved: false` *and*
`hasClaudeMdExternalIncludesWarningShown: false` — the approval dialog has
never even fired in this environment (sessions run through the VS Code
extension).

**Design consequence:** the approval is per-project × per-machine mutable
state with a silent failure mode — and every git worktree is a distinct
project path needing its own approval, which collides with the
concurrent-agents rule that feature work happens in worktrees. So this design
**stops relying on project-level external imports entirely**: no repo
CLAUDE.md keeps an `@~/.claude/...` line. The mechanism and its gate get
recorded in ADOPTING.md so the lesson is not relearned.

## What stays unchanged

- **The `~/.claude/dcltdw` symlink and `core.hooksPath` (Finding 2).** The
  migration proved the indirection's worth: one repoint kept the AGENTS.md
  import, `core.hooksPath`, and the marketplace working, where a dangling
  `core.hooksPath` was verified to disable all git hooks silently. The
  symlink still carries always-loaded prose and `githooks/` — both verified
  (CC 2.1.233) impossible to deliver via plugin. ADOPTING.md's "revisit
  retiring the symlink when Claude Code ships all three" criteria remain the
  standing policy; this design does not touch them.
- **Plugin-cache ride-alongs.** `AGENTS.md`/`ADOPTING.md` copies frozen in
  the cache remain inert and are left alone; the hazard is already
  documented in ADOPTING.md's delivery-paths section. Restructuring the
  plugin root would mean moving the marketplace source and re-verifying the
  delivery chain — not worth it.

## Decision (Finding 3): a `dcltdw:garmin-release` skill

The 44-line release procedure is skill-shaped — a numbered procedure plus a
checklist, needed at one specific moment — and the plugin mechanism the last
initiative built delivers exactly that with no per-repo wiring and no
approval state.

Alternatives considered and rejected:

- **Read-pointer prose** (keep the file symlink-delivered; repo CLAUDE.md
  tells sessions to read it explicitly). Cheapest, but converts a guaranteed
  mechanism into an instruction-following bet, keeps per-repo human wiring,
  and to *trust* it you'd want to baseline-test it — paying much of the
  skill's cost without its robustness.
- **Approve the external imports** (flip the per-project approval). Fragile
  per-project/per-machine/per-worktree mutable state, silent failure mode,
  dialog demonstrably not surfacing in this environment, and ADOPTING.md
  would have to document an approval dance for every adopter and machine.

### The skill

- `claude/skills/garmin-release/SKILL.md`, namespaced `dcltdw:garmin-release`.
- **Trigger-only description** (never a workflow summary), e.g.: "Use when
  releasing a Garmin Connect IQ app or watch face — cutting a store release,
  building/signing the `.iq`, updating store copy, or tagging a release."
  Final wording set during implementation.
- **Body:** the ported procedure (pre-release checklist + numbered steps)
  from `claude/garmin-release.md`, *minus* its "Project supplement" section —
  that section is wiring instructions for humans, and moves to ADOPTING.md's
  per-repo wiring. Content changes beyond the port are made **only against
  observed baseline failures** (writing-skills: piling guidance where a
  control already passes measurably degrades skills).
- `claude/garmin-release.md` is **deleted in the same PR**. No delivery gap:
  the project import never loaded it, so removing the target loses nothing
  any session currently has.
- `claude/.claude-plugin/plugin.json`: `version` 0.2.0 → **0.3.0** (same PR —
  the standing rule for `claude/skills/**`), and its `description` (plus the
  mirrored plugin description in `.claude-plugin/marketplace.json`) broadens
  beyond "PR lifecycle skills" to cover release skills.

## TDD design (writing-skills)

- **RED before any SKILL.md.** Scenario prompts run as fresh sessions in the
  Garmin repos' context, graded against the procedure's load-bearing
  behaviors: scope-diff against the last release tag; signing-key
  verification by RSA-modulus match; artifact re-verification; store-copy
  rules (4000-char cap, history move); secret scan; tag; and the hand-off
  framing (the human uploads; a release is unconfirmed until the wild says
  otherwise). Prompts are advisory-phrased ("lay out exactly what you would
  do to cut vX.Y.Z — do not execute") so nothing mutates the repos.
- **No clean room needed — record this explicitly.** The last initiative's
  clean room existed because AGENTS.md contaminated every subagent. Here the
  content under test *never loads* (that is the defect), so a fresh session
  in a Garmin repo already **is** the naive agent. The two documented "not
  in context" transcripts are evidence of the delivery failure; the baseline
  adds the behavioral failure record.
- **Expect partial passes, and calibrate.** Flightdeck's CLAUDE.md
  supplement plus `tools/release.sh` already cover key verification there;
  Understated (no release automation) is the sharper baseline. Whatever the
  control already does unprompted, the skill does not belabor.
- Raw transcripts under `.superpowers/sdd/2026-08-17-garmin-release-skill/`
  (gitignored);
  the graded baseline write-up is committed under `docs/superpowers/`, same
  pattern as the last initiative.
- **GREEN** by injection (skill content supplied to the same scenarios);
  **REFACTOR** only against observed failures.
- **Live trigger check is deferred to rollout** (below) — it can only run
  once 0.3.0 is installed on the machine.

## Changes by repo

**PR A — `dcltdw/agents`** (one PR, on a branch):

- Add `claude/skills/garmin-release/SKILL.md`; delete `claude/garmin-release.md`.
- `claude/.claude-plugin/plugin.json`: version 0.3.0 + broadened description;
  `.claude-plugin/marketplace.json`: mirrored plugin description.
- `claude/ADOPTING.md`: intro's canonical-files list; Garmin per-repo wiring
  section rewritten (no import line; supplement guidance absorbed from the
  deleted file; the repo-CLAUDE.md pointer line documented); delivery-paths
  file examples updated; "How resolution works" rewritten to record the
  external-import approval gate (user-scope imports resolve unconditionally;
  project-scope imports crossing the working-dir boundary are approval-gated
  and silently inert when unapproved).
- Repo `CLAUDE.md` (symlink-delivered list): drop `garmin-release.md`.
- `install.sh` closing hint (currently "Garmin repos: add
  '@~/.claude/dcltdw/garmin-release.md' …"): retargeted to the supplement +
  pointer wiring per ADOPTING.md.
- Baseline write-up committed under `docs/superpowers/`.
- Historical specs/plans under `docs/superpowers/` are left untouched.

**PR B — Flightdeck; PR C — Understated** (one small PR each, in their own
repos): delete the "The Garmin store-release process is shared…" paragraph
and the `@~/.claude/dcltdw/garmin-release.md` line; add a one-line
always-loaded pointer — "Store releases: use the `dcltdw:garmin-release`
skill; project specifics in the release supplement below." — the same
guaranteed-trigger pattern AGENTS.md uses for the PR skills. The release
supplements and board sections stay. Flightdeck's `docs/releasing.md` is
repo-local and untouched.

## Tracking

Three cross-linked issues, one per repo, so each PR is associated with an
issue in its own repo explaining what is going on:

- `dcltdw/agents`: the umbrella issue — Finding 1's cause, the skill fix,
  links to the two repo issues. Tracked on the **Agent tooling** board
  (project 8), per this repo's CLAUDE.md.
- `Flightdeck` and `Understated`: one issue each for the CLAUDE.md rewiring,
  linking the umbrella. Tracked on their own boards (projects 5 and 3).
- Each PR references and closes its repo's issue; board moves per the PR
  skills.

## Rollout order and verification

1. PR A merges first (user merges, never self-merge). Then on this machine:
   `git pull` + `./install.sh` → plugin update picks up 0.3.0. The deleted
   file leaves the symlink at the same moment the skill arrives in the
   cache; no gap either way.
2. **Live trigger check** (the real GREEN-in-production, mirroring the last
   initiative's cutover step 5): fresh session in a Garmin repo with a
   release-shaped request → expect "Using dcltdw:garmin-release".
   `./install.sh --check` must still pass (none of its four checks reference
   `garmin-release.md` — verified against the current script).
3. PRs B and C merge after the skill is live, so their pointers never name a
   skill the machine doesn't have.
4. Rollback: revert PRs; plugin versions move forward only (a revert would
   ship as 0.3.1 carrying the removal).

## Constraints compliance

- `~/.claude/dcltdw` symlink and `core.hooksPath` untouched throughout.
- Version bump in the same PR as the `claude/skills/**` change.
- No commits to `main`; every change lands via PR with approval gates.
- gitleaks pre-push hook is armed; scans run on every push, fail closed on
  scan errors.
- writing-skills Iron Law: no SKILL.md before the documented failing
  baseline; trigger-only description; no guidance piled where the control
  passes.

## Risks and accepted trade-offs

- **Delivery latency changes shape:** the procedure moves from live-on-pull
  (symlink) to version-gated (plugin cache). Accepted — a release procedure
  needed at one specific moment doesn't need live delivery, and the version
  bump rule is established practice.
- **Skill quality risk:** over-teaching degrades skills; guarded by the
  baseline-calibrated port and the REFACTOR-only-against-failures rule.
- **The external-import gate may change upstream.** If Claude Code later
  makes external imports workable (e.g. durable approval via settings),
  nothing here needs undoing — the skill remains the better shape for this
  content. ADOPTING.md's revisit criteria for the *symlink* are unaffected.
