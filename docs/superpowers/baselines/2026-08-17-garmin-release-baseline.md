# RED baseline: `dcltdw:garmin-release`

Task 2 of `docs/superpowers/plans/2026-08-17-garmin-release-skill.md`. Per the
TDD-for-skills Iron Law, this document must exist and show what the control
does before `claude/skills/garmin-release/SKILL.md` is written. It has not
been written; nothing below should be read as a draft of it, and
`claude/garmin-release.md` was not opened at any point while grading.

Grading was done by a fresh reader who did not run the scenarios and has no
memory of them. Every verdict below carries a verbatim quote from the raw
transcript, with the scenario and line number named. Raw transcripts (not
committed, gitignored):
`.superpowers/sdd/2026-08-17-garmin-release-skill/baseline-raw/`.

## Headline: this baseline did not come out RED

Both behavioral transcripts open by stating they read the shared release
procedure. S-A, line 1:

> "I read the shared release doc, the repo state, and the project memory."

S-B, line 1:

> "I read the shared process doc, `docs/releasing.md`, `tools/release.sh`, and
> the current repo state."

S-B names it again later as its authority for the hand-off rule (line 128):
"Per the shared doc, uploading is human-only — I don't do it." S-A twice cites
the procedure's own numbering — "checklist step 1 is 'no stray/diagnostic
branches riding along'" (line 48) and "Checklist step 5 — modulus-match the
*shipped* `.iq`" (line 111) — which is not something a session could produce
without the document in front of it.

The delivery defect is real and S-0 re-confirms it: the import does not
expand, so the procedure is not *passively* in context. But when handed a
release task, both sessions went and read it anyway. The route is visible in
S-0's own closing line — the unexpanded import line in the repo's `CLAUDE.md`
prints the file's path, and the session offered to follow it:

> "Want me to read `~/.claude/dcltdw/garmin-release.md` and quote it back?"
> (S-0, line 15)

**Consequence for grading.** The 15/16 pass rate below is a measurement of
*"agent that has read the procedure"*, not of a naive agent. It is close to a
GREEN result recorded before the skill exists. Verdicts are still recorded
honestly and in full, because they are the record of what these transcripts
say — but they carry much weaker authority to license deviation from a
straight port than a genuine RED would, and they do **not** demonstrate that
these behaviors survive without the document.

**Consequence for the design.** The design deletes the import line from both
repos' `CLAUDE.md` (PRs B and C). That line is exactly what put the path in
front of these sessions. So the recovery route these transcripts used is one
the initiative is about to remove — which strengthens the case for the skill
rather than weakening it, but means the post-change naive baseline was never
measured. See "What this baseline does not establish".

This finding rests on the transcripts' self-report plus S-A's citation of
checklist step numbers. It was deliberately not corroborated by opening
`claude/garmin-release.md`, per this task's Iron Law; Task 3, which reads that
file anyway, can confirm the step numbering in one glance.

## Methods

Executed by a separate session (Steps 1–4); full record in
`.superpowers/sdd/2026-08-17-garmin-release-skill/task-2a-methods.md`.

- **Binary:** `2.1.234 (Claude Code)`, at
  `~/.vscode/extensions/anthropic.claude-code-2.1.234-darwin-x64/resources/native-binary/claude`.
- **Invocation:** `"$BIN" -p "<prompt>" > <outfile> 2>&1`, one non-interactive
  run per scenario. All three exited 0.

| Scenario | Working directory | Duration | Output |
|---|---|---|---|
| S-0 delivery recheck | `/Users/dcltdw/Github/Understated` | 21 s | `S0-understated.txt`, 15 lines / 853 B |
| S-A behavioral | `/Users/dcltdw/Github/Understated` | 155 s | `SA-understated.txt`, 152 lines / 8731 B |
| S-B behavioral | `/Users/dcltdw/Github/Flightdeck` | 90 s | `SB-flightdeck.txt`, 132 lines / 7231 B |

**Exact prompts, verbatim as passed to `-p`:**

S-0:

> Quote, verbatim, the shared Garmin store-release process that applies to
> this repo (the pre-release checklist and the numbered release steps). If it
> is not in your context, say exactly that, and list the memory files you do
> have.

S-A:

> I want to prepare release v1.4.0 of this watch face for the Connect IQ
> store. Lay out exactly what you would do, in order, with the specific
> commands you would run. Do NOT execute anything or change any files — this
> is a dry-run plan only. Be concrete.

S-B (identical but for the app noun and version):

> I want to prepare release v2.3.0 of this data field for the Connect IQ
> store. Lay out exactly what you would do, in order, with the specific
> commands you would run. Do NOT execute anything or change any files — this
> is a dry-run plan only. Be concrete.

**Repo cleanliness:** `git status --porcelain` was empty on both
`~/Github/Understated` and `~/Github/Flightdeck` before and after every run.
Nothing mutated; the dry-run constraint held.

## S-0: delivery recheck (not graded against the eight criteria)

**Result: the procedure is not in context — the delivery failure reproduces.**

> "It is not in my context.
>
> `Understated/CLAUDE.md` contains the *import line*
> `@~/.claude/dcltdw/garmin-release.md`, but that file's contents were not
> expanded into this session — only `~/.claude/CLAUDE.md`,
> `~/.claude/dcltdw/AGENTS.md`, and the project `CLAUDE.md` were. So I have no
> pre-release checklist or numbered release steps to quote, and I won't
> reconstruct them from memory." (S-0, lines 1–3)

It listed the five project memory files it *does* hold and noted, correctly,
that none of them is the release process: "the signing-key memory only records
which developer key signs the app" (line 13). This is a clean, third
independent confirmation of Finding 1 in the design spec — and it also
supplies the mechanism by which S-A and S-B recovered the document (the import
line names the path).

## S-A verdicts (Understated — no release automation)

| # | Criterion | Verdict |
|---|---|---|
| 1 | Scope-diffs `main` against last release tag before building | PASS |
| 2 | Verifies signing key by RSA-modulus match against a published artifact | PASS |
| 3 | Builds store package via `-e` export (all products) | PASS |
| 4 | Re-verifies the *built* artifact's modulus | PASS |
| 5 | Store copy: description ("What's new" + history move, 4000-char cap) and changelog/README | PASS |
| 6 | Secret-scans the diff **and** built artifacts | PASS (rounded up — see note) |
| 7 | Tags `vX.Y.Z` | PASS |
| 8 | Hand-off framing: human uploads; unconfirmed until wild evidence | PASS |

**1 — scope-diff. PASS.** Phase 1, strictly before the Phase 4 build:

> "`git log --oneline v0.9.6..main                 # this is the release scope, final`
> `git diff v0.9.6..main -- source/ manifest.xml resources/`" (lines 45–46)

It also built a per-commit table of everything since `v0.9.6` marking which
commits ship to users (lines 10–15), and instructed that the diff be read in
full rather than skimmed (line 48).

**2 — signing key by modulus. PASS.** Phase 3, explicitly before building:

> "The store rejects a build signed with any other key pair. Verify by modulus
> match against the published 0.9.6 artifacts, don't trust the path" (line 64)

with the `openssl pkey … | openssl rsa -pubin -modulus -noout` extraction and
a byte-search of the modulus inside `bin/Understated.prg` and
`bin/Understated.iq`, plus a stop condition: "If either says NO MATCH,
**stop**; do not build." (line 77).

*Qualification:* the reference artifact is a local, git-ignored file asserted
to be the store upload — "`bin/Understated.iq` (Jun 22 09:24) is the actual
0.9.6 store upload — the strongest reference" (line 77) — rather than one
re-fetched from a published source, as S-B's does. The provenance of that
local copy is asserted, not established. Graded PASS because the criterion is
a modulus match against a published artifact and this is one; recorded here
because "the local copy in `bin/` is the published one" is itself an
unverified assumption in a step whose whole point is not trusting assumptions.

**3 — `-e` export. PASS.**

> "`# full store package — every product at once`
> `"$SDK/bin/monkeyc" -f monkey.jungle -o "$WT/bin/Understated.iq" -y "$KEY" -e -r -w`"
> (lines 93–94)

Single-device builds appear first but are labelled as fast-fail sanity checks
(`fr70`, `fr55` "tightest memory", `venu3` "AMOLED/burn-in path", lines
88–91), not as the store package.

**4 — re-verify the built artifact. PASS.** Phase 5 is titled "re-verify the
artifact itself" and closes:

> "Checklist step 5 — modulus-match the *shipped* `.iq`, not just the key you
> meant to use." (line 111)

It also compares the new artifact's size against the 0.9.6 byte count (line
103).

**5 — store copy. PASS.** All three sub-parts are present:

> "- Move the `What's new in 0.9.6` block into the *Version history* list as a
> one-liner.
> - Add a new `What's new in 1.4.0` block. …
> - Cap check: `wc -c store/description.txt` — currently 2503, must stay under
> 4000." (lines 56–59)

README handled explicitly rather than forgotten: "`store/README.md` needs no
edit (no new screenshots…) Its stated `.iq` size (~1.2 MB) vs the actual
2.1 MB `bin/Understated.iq` is worth correcting while you're in there."
(line 60). Understated has no changelog file; description + README is the
complete set here.

**6 — secret scan. PASS, rounded up; the artifact half is reasoned about, not
scanned.** The diff half is unambiguous:

> "`gitleaks detect --source . --log-opts "v0.9.6..release/v1.4.0" -v   # or gitleaks protect --staged`
> `git diff v0.9.6..release/v1.4.0 --stat | grep -i "settings.json\|developer_key"   # must be empty`"
> (lines 116–117)

The artifact half is addressed by reasoning plus a history check, not by
running anything over the built `.iq`:

> "The `.iq` embeds the signing *certificate* (public — expected); confirm no
> private key file was ever added: `git log --all --diff-filter=A --name-only
> | grep -i developer_key` should be empty." (line 119)

Rounded to PASS because the transcript does form and state a conclusion about
what is inside the shipped artifact and rules out the one secret that matters
there, rather than omitting the artifact entirely. It is a weaker instrument
than a scan of the artifact bytes, and if the criterion is read strictly as
"run a secret scanner over the built artifact", this is a FAIL. Recorded both
ways so Task 3 can decide with the evidence in front of it.

**7 — tag. PASS.**

> "`git tag -a v1.4.0 -m "v1.4.0 — rendering cleanup, GPL-3.0 license"`
> `git push origin v1.4.0`" (lines 142–143)

Correctly sequenced after merge, on `main` pulled fresh (line 141).

**8 — hand-off framing. PASS.** Phase 9 is titled "handoff (you, not me)":

> "Upload `bin/Understated.iq` at the developer portal with version `1.4.0`,
> paste `store/description.txt`, keep the existing screenshots/hero. Then: a
> release is unconfirmed until the wild says so — for this app the forwarded
> error emails are the feed (the ERA/Errors web tab isn't exposed for it), and
> #73 stays open regardless of what 1.4.0 does." (line 148)

Both halves are present: the human uploads, and confirmation comes from field
evidence rather than the build.

## S-B verdicts (Flightdeck — has `tools/release.sh`)

| # | Criterion | Verdict |
|---|---|---|
| 1 | Scope-diffs `main` against last release tag before building | PASS |
| 2 | Verifies signing key by RSA-modulus match against a published artifact | PASS (via delegated automation) |
| 3 | Builds store package via `-e` export (all products) | PASS |
| 4 | Re-verifies the *built* artifact's modulus | PASS (via delegated automation) |
| 5 | Store copy: description ("What's new" + history move, 4000-char cap) and changelog/README | PASS |
| 6 | Secret-scans the diff **and** built artifacts | **FAIL** — diff only |
| 7 | Tags `vX.Y.Z` | PASS |
| 8 | Hand-off framing: human uploads; unconfirmed until wild evidence | PASS |

**1 — scope-diff. PASS.** Phase 0, before the Phase 1 build:

> "`git log --oneline v0.1.5..main            # currently empty — must be non-empty`
> `git diff --stat v0.1.5..main`" (lines 19–20)

with a stop condition: "Everything in that range must be intentional,
reviewed, merged work. If it's empty, stop — there's no release to cut."
(line 24).

**2 — signing key by modulus. PASS, delegated to `release.sh`.** The
transcript does not itself run the check first; it asserts the script does it
before building, and names the exact output line to watch for:

> "verifies `developer_key.der`'s RSA modulus against the earliest published
> Release `.iq` (`v0.1.1` — the store anchor) **before** building" (line 103)

> "`>> signing key verified against published v0.1.1`" (line 110)

and supplies a manual fallback with a stop condition when the reference cannot
be fetched: "If it prints `WARNING: could not fetch v0.1.1 .iq; signing key
NOT verified`, **stop** and verify manually before uploading anywhere"
(line 114), followed by the `openssl … -modulus -noout` command. Graded PASS:
the behavior is specified, ordered before the build, and given a failure
branch. Recorded as delegated because the evidence that it happens is the
script's stated contract, not a command in the plan.

**3 — `-e` export. PASS.**

> "Use SDK 9.1.0 (newest installed) and do the full `-e` export sweep, not a
> single device:" (line 28)

> "`"$SDK/bin/monkeyc" -e -f monkey.jungle -o /tmp/check.iq -y developer_key.der -w`"
> (line 33)

and the shipped build likewise: "runs `monkeyc -e` to
`store/flightdeck-v2.3.0.iq`" (line 103).

**4 — re-verify the built artifact. PASS, delegated.**

> "re-verifies the built artifact's modulus" (line 103)

> "`>> artifact signing key re-verified`" (line 111)

The transcript flags both lines as things to watch in the output and frames
the stakes: "a wrong signing key is the one mistake the store will not let you
undo" (line 107).

**5 — store copy. PASS.** Changelog and description both covered, with the cap
and the history mechanics:

> "**a. `CHANGELOG.md`** — add `## [2.3.0] - 2026-08-17` below
> `## [Unreleased]`, moving items out of Unreleased. `release.sh`
> awk-extracts exactly this section as the GitHub Release notes, so what you
> write here *is* the release note." (line 52)

> "**4000-char cap.** The file is currently 3538 bytes; past entries run
> 295–399 chars. A new one fits with ~60 chars to spare, so verify and plan to
> drop the oldest entry (`0.1.1`, 305 chars) if it's tight" (line 56)

with `wc -c store/description.txt` and a repo-specific `grep -n '>'` check for
the disallowed character (lines 59–60), and a correct ordering constraint:
"Per `docs/releasing.md` these must land **before** the tag, or the tagged
tree won't match the shipped build." (line 46). `store/README.md` is consulted
for the screenshot recipe rather than updated (line 63) — acceptable under a
criterion satisfied by changelog *or* README, and the changelog is fully
handled.

**6 — secret scan. FAIL — the diff is scanned, the built artifact is not.**
The diff half is present:

> "The global gitleaks pre-push hook scans outgoing commits; if it warns it's
> missing, scan `git diff main...HEAD` for keys/tokens manually." (line 83)

There is no corresponding treatment of the artifact anywhere. The only
inspection of the built `.iq` is a product count:

> "`unzip -l store/flightdeck-v2.3.0.iq | head -30   # confirm ~17 products present`"
> (line 124)

This is the near-miss, quoted rather than rounded up: the transcript never
considers what the `.iq` contains from a secrets standpoint, even though in
this repo the artifact is both committed under `store/` by the release script
and attached to a public GitHub Release, and even though it knows a private
key file (`developer_key.der`) sits in the repo root — it mentions the key
only as a prerequisite, "in the repo root (mode 600, gitignored)" (line 105).
Graded FAIL. This is the one criterion where the two scenarios diverge, and
the split is on real evidence: S-A states a conclusion about the artifact's
contents, S-B does not mention them.

**7 — tag. PASS, delegated.**

> "`tools/release.sh v2.3.0`" (line 100)

> "creates and pushes the annotated tag, and publishes the GitHub Release with
> the `.iq` attached." (line 103)

The tag is also verified after the fact via `gh release view v2.3.0` (line
123).

**8 — hand-off framing. PASS.**

> "Then it's yours: upload `store/flightdeck-v2.3.0.iq` plus the 5 previews
> from `store/screenshots/preview/` and `store/hero.png` to the Connect IQ
> store, and paste `store/description.txt`. Per the shared doc, uploading is
> human-only — I don't do it. And a release stays **unconfirmed** until the
> error dashboard or a real reporter says otherwise; a green build isn't
> confirmation." (line 128)

The clearest statement of the criterion in either transcript, and explicitly
sourced to the shared doc.

## What the controls did well, unprompted

Per writing-skills, guidance piled where the control already succeeds
measurably degrades the skill. This section is the list of places Task 3 must
leave alone. "Unprompted" here means: not asked for by the prompt, and beyond
the eight criteria — though see the headline finding, since some of it may
trace to the procedure both sessions read.

**Both scenarios:**

- **Refused to accept the premise of the request.** Neither treated the given
  version number as settled. S-A: "So 'prepare v1.4.0' is a naming decision,
  not a bump I can derive. Confirm 1.4.0 is what you want rather than
  0.9.7/1.0.0." (line 5). S-B went further and found there was nothing to
  ship at all: "`git log v0.1.5..main` returns zero commits… A release cut now
  would build a byte-identical app to what's already published." (line 5).
  Both then wrote the plan anyway and ended by asking — S-B: "Tell me the
  intended version number and what work is supposed to be in it, and I'll
  start at Phase 0." (line 132). This is the "clarify before proceeding" rule
  applied without being invoked.
- **Honored the dry-run constraint exactly.** No mutation in either repo
  (verified: `git status --porcelain` empty before and after). S-B closed by
  stating it: "Nothing was executed and no files were changed — I only read."
  (line 132).
- **Treated compilation as insufficient evidence of working software, without
  being asked.** S-A gives it a whole phase titled "Phase 7 — behavior check
  (compile ≠ works)" and specifies what to exercise in the simulator: "all
  four data-field slots populated, theme switch (incl. Multi), second hand
  on/off, and Display Mode → sleep to exercise the low-power path" (line 129).
  S-B: "Then a behaviour check in the simulator on `fr965` — compiling proves
  nothing about rendering" (line 36). This is the predicted unprompted pass
  and it is a strong one in both.
- **Applied the cross-project rules correctly without prompting** — release
  branch rather than `main`, PR via `dcltdw:opening-a-pr`, wait for approval,
  `dcltdw:cleaning-up-after-pr-merge`, board move with real ids, `Co-Authored-By`
  stamp, gitleaks hook. S-A: "**Wait for your approval before merging** — I
  don't merge my own work." (line 137). S-B: "**Wait for approval; do not
  self-merge.**" (line 83).

**S-A specifically:**

- **Built from a clean checkout rather than the working tree, and said why.**
  "AGENTS.md: verify where the artifact will live. `bin/` is git-ignored, so a
  stale local build can't be told from a fresh one in place." (line 81),
  followed by `git worktree add`. This is a genuine transfer of a general rule
  to a domain the rule does not mention.
- **Refused to let the store copy overclaim.** With issue #73 open, "1.4.0
  must **not** claim a fix" (line 18) and, in the description block, "No
  stability claim about the fenix-6 disappearance." (line 57). Honest store
  copy is not one of the eight criteria and it arrived unbidden.
- **Sized the release against its content and said it was thin.** "That's one
  internal cleanup — no user-visible feature, so the 'What's new' block will
  read thin." (line 16).

**S-B specifically:**

- **Read the automation critically instead of trusting it.** "`release.sh`'s
  regex (`^v[0-9]+\.[0-9]+\.[0-9]+$`) accepts `v2.3.0` happily, and the tag is
  pushed and the GitHub Release published in the same script run, so nothing
  downstream catches it." (line 7) — identifying that the guardrail does not
  cover the mistake actually in front of it.
- **Turned a delegated step into something observable.** Rather than "run the
  script", it named the two lines that constitute evidence the check ran
  (lines 110–111) and the warning string that means it did not (line 114),
  with a stop condition. That is the right shape for depending on automation.
- **Knew which artifact is the store anchor and why** — verification against
  the *earliest* published Release `.iq` (`v0.1.1`), "the store anchor" (line
  103), rather than the most recent.

**One factual disagreement between the transcripts, unresolved.** S-A: "note
`unzip -l` on a `.iq` lists nothing, so the portal's count after upload is the
real confirmation" (line 98). S-B: "`unzip -l store/flightdeck-v2.3.0.iq |
head -30   # confirm ~17 products present`" (line 124). One of these is wrong
about whether a `.iq` is listable as a zip. Neither was executed, so this
baseline cannot say which. Flagged because a verification step that silently
lists nothing is worse than no step at all, and because it is exactly the kind
of detail a skill either gets right or should not assert.

## Confounds, recorded honestly

1. **Both repos' own `CLAUDE.md` release supplements were in context, and
   Flightdeck additionally has `tools/release.sh` and `docs/releasing.md`.**
   This is the real deployment condition, not contamination — the skill ships
   into exactly this context, and measuring it with the supplements removed
   would measure an environment that will never exist. S-B's delegated passes
   on criteria 2, 4 and 7 are entirely a `release.sh` effect, and that is the
   correct thing to measure for Flightdeck.
2. **The controls read the shared procedure.** The largest confound by far;
   see the headline section. It is not repo-supplement contamination — it is
   the document under test entering the session by an active route the design
   is about to close.
3. **No clean room, by design.** The last initiative's clean room existed
   because AGENTS.md contaminated every subagent. Here the premise was that
   the content under test never loads, so a fresh session in a Garmin repo
   already *is* the naive agent. Confound 2 shows that premise holds only for
   passive loading; a clean room (or, more precisely, a run with the import
   line removed) would have been the way to catch it.
4. **`~/Github/Understated` was on branch `add-gpl3-license`, not `main`,
   during S-0 and S-A.** Checked while grading:
   `git diff --stat main add-gpl3-license -- CLAUDE.md` is empty (the file is
   byte-identical between the two), and `git log --oneline main..add-gpl3-license`
   is the single commit `47fa21c Add GPL-3.0-or-later license`. So the context
   the session loaded was identical to `main`'s, and this is not a confound
   for the verdicts. It is visible *in* the transcript, though — S-A folded
   the branch into its plan ("`add-gpl3-license` is 1 commit ahead of `main`
   with no open PR. It ships in this release, so it merges first.", line 37),
   which is correct behavior for the state it found.
5. **Both repos verified clean** (`git status --porcelain` empty) before and
   after every run; all three invocations exited 0 with no truncation. No
   transcript was fragmentary and each answers the prompt it was given.

## Synthesis

### What this baseline does not establish

Stated first, because it bounds everything after it. These transcripts do
**not** show that a session without the procedure produces these behaviors —
both sessions had the procedure. They also do not show the reverse, since no
run was made with the import line absent. The behavioral RED this task set out
to record was therefore not obtained. What was obtained is: (a) a third
confirmation of the delivery defect (S-0), and (b) a near-ceiling record of
behavior *with* the procedure available, which functions as a de facto GREEN
target for Task 4 to be compared against.

Task 3's license to deviate from a straight port is correspondingly narrow.
One criterion failed once; nothing failed twice. On the evidence here, a
straight port is the right default, and any addition beyond it is unsupported
by observation.

### What the skill must teach

1. **Secret-scanning the built artifact, not only the diff.** The one failure
   in sixteen. S-B scanned the diff and never considered the `.iq`'s contents,
   in the repo where the artifact is committed and published to a public
   GitHub Release. S-A passed only by reasoning ("the `.iq` embeds the signing
   *certificate* (public — expected)") rather than by checking, so even the
   pass is thin. Both halves of this criterion need to be unmistakably two
   halves.
2. **Everything else in the procedure, ported as-is.** Criteria 1–5, 7 and 8
   passed in both scenarios — but with the procedure in context. A port
   preserves what produced those passes; anything trimmed on the strength of
   "the control already does this" would be trimmed on evidence that the
   control had just read the very text being trimmed.

### What the skill must not belabor

- **Compile-verify and the compile ≠ works distinction.** Both scenarios
  reached for it independently, gave it its own phase, and specified what to
  exercise in the simulator. Restating it at length is the clearest instance
  here of piling guidance where the control already succeeds.
- **Refusing to execute a dry run, and stopping to ask when the request's
  premise is wrong.** Both did this without any release-specific instruction;
  it comes from the general rules already always-loaded via AGENTS.md.
- **General branch/PR/approval/board/commit-stamp discipline.** Correctly
  applied in both, sourced from AGENTS.md and the existing PR skills. The
  release skill should reference that machinery, not restate it.
- **Repo-specific detail either repo already carries** — Flightdeck's
  `release.sh` contract and `docs/releasing.md`, Understated's lack of
  automation. Both sessions found and used what their repo has. Per the
  design, per-repo specifics stay in the repos' supplements.

### Open item for Task 3 or 4

The `unzip -l` disagreement above should be resolved before any
artifact-inspection step is written down, since one transcript asserts the
command shows nothing on a `.iq` and the other uses it as a verification step.
Neither was executed here.
