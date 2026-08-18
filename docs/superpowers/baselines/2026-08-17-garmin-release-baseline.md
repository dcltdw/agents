# RED baseline: `dcltdw:garmin-release`

Task 2 of `docs/superpowers/plans/2026-08-17-garmin-release-skill.md`. Per the
TDD-for-skills Iron Law, this document must exist and show what the control
does before `claude/skills/garmin-release/SKILL.md` is written. It has not
been written; nothing below should be read as a draft of it, and
`claude/garmin-release.md` was not opened at any point while grading either
condition.

**This document was amended after its first version.** The baseline was run
twice, under two different conditions, and only the second is a RED baseline.
Both are recorded in full: the first because its failure is itself a finding,
the second because it is the control the skill must be calibrated against.
Grading of each condition was done by a fresh reader who did not run the
scenarios and, for condition 2, wrote its verdicts before reading condition
1's. Every verdict carries a verbatim quote from the raw transcript with the
scenario and line number named. Raw transcripts (not committed, gitignored):
`.superpowers/sdd/2026-08-17-garmin-release-skill/baseline-raw/`.

## Headline: the first condition was not RED; the second one is

**Condition 1 (the original run) measured the wrong thing.** Both behavioral
transcripts open by stating they read the shared release procedure, and both
scored near ceiling — 15/16. The route is visible in S-0's own closing line:
the repo `CLAUDE.md` carries an import (`@~/.claude/dcltdw/garmin-release.md`)
that never expands into a session's loaded context — that is the delivery
defect under repair — but the dead line still **prints the file's path**, and a
session with a Read tool follows it:

> "Want me to read `~/.claude/dcltdw/garmin-release.md` and quote it back?"
> (S-0, line 15)

So the "control" had the document in hand. A 15/16 pass rate by sessions
holding the procedure is closer to a pre-emptive GREEN than to a RED.
("Loaded context" is the deliberate qualifier: passive loading never happens,
which is the defect — but a tool-initiated `Read` of the *importing* file does
surface the import's content in this harness. See Limitation 4.)

**This falsifies a premise the design spec states explicitly** — that no clean
room is needed because

> "the content under test *never loads* (that is the defect), so a fresh
> session in a Garmin repo already **is** the naive agent"
> (`docs/superpowers/specs/2026-08-17-garmin-release-skill-design.md`, lines
> 107–112)

The premise holds for **passive** loading and fails for **active recovery**.
The import genuinely does not expand — S-0 confirms this for a third time, and
that diagnosis stands untouched. What the spec did not anticipate is that a
non-expanding import is still a *pointer*, and an agent handed a release task
will go and read what the pointer names. This is a correction to the spec's
reasoning about how to measure the baseline, not a defect in the initiative's
direction: the initiative is about to delete that import line (PRs B and C),
which closes the recovery route and makes the skill more necessary, not less.

**Condition 2 (the re-run) removed the pointer** — the import block was deleted
in place from each repo's `CLAUDE.md` for the duration of the run and restored
immediately after — so the session had neither the procedure nor a path to it.
That is the end-state condition, and it produced a genuine RED: **S-A 6/8, S-B
5/8**, with criterion 6 failing in both. Condition 2 governs the synthesis.
Condition 1 is retained below because it explains something the initiative
needed explaining — why nobody noticed the import was dead — and because it is
evidence that the procedure's content works when an agent has it.

## Condition 1 — pointer present (not the baseline)

Retained in full. Read these verdicts as *"what an agent does when it has just
read the shared procedure"*, which is what they measure.

### Methods

Executed by a separate session (plan Steps 1–4); full record in
`.superpowers/sdd/2026-08-17-garmin-release-skill/task-2a-methods.md`.

- **Binary:** `2.1.234 (Claude Code)`, at
  `~/.vscode/extensions/anthropic.claude-code-2.1.234-darwin-x64/resources/native-binary/claude`.
- **Invocation:** `"$BIN" -p "<prompt>" > <outfile> 2>&1`, one non-interactive
  run per scenario. All three exited 0.
- **CLAUDE.md condition:** unmodified — the import line present but
  non-expanding.

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

### The recovery evidence

S-A, line 1: "I read the shared release doc, the repo state, and the project
memory." S-B, line 1: "I read the shared process doc, `docs/releasing.md`,
`tools/release.sh`, and the current repo state." S-B names it again as its
authority for the hand-off rule (line 128): "Per the shared doc, uploading is
human-only — I don't do it." S-A twice cites the procedure's own numbering —
"checklist step 1 is 'no stray/diagnostic branches riding along'" (line 48)
and "Checklist step 5 — modulus-match the *shipped* `.iq`" (line 111) — which
is not something a session could produce without the document in front of it.

This finding rests on the transcripts' self-report plus S-A's citation of
checklist step numbers. It was deliberately not corroborated by opening
`claude/garmin-release.md`, per this task's Iron Law; Task 3, which reads that
file anyway, can confirm the step numbering in one glance.

### S-A verdicts, condition 1 (Understated — no release automation)

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

### S-B verdicts, condition 1 (Flightdeck — has `tools/release.sh`)

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

*Noted for the cross-condition comparison below:* the 4000-char cap is **not**
in Flightdeck's `CLAUDE.md` supplement. In this repo the shared doc is the only
place it could have come from.

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
Graded FAIL.

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

**Condition 1 tally: S-A 8/8, S-B 7/8 — 15/16.** Failed in both: none. Failed
in one: criterion 6, S-B only.

### What the condition-1 controls did well, unprompted

Retained as recorded, but **superseded for planning purposes** by the
condition-2 list further down: some of what follows may trace to the procedure
both sessions had just read, and at least one item demonstrably does not
survive its removal. Read it as observation, not as licence.

**Both scenarios:**

- **Refused to accept the premise of the request.** S-A: "So 'prepare v1.4.0'
  is a naming decision, not a bump I can derive. Confirm 1.4.0 is what you want
  rather than 0.9.7/1.0.0." (line 5). S-B went further and found there was
  nothing to ship at all: "`git log v0.1.5..main` returns zero commits… A
  release cut now would build a byte-identical app to what's already
  published." (line 5). Both then wrote the plan anyway and ended by asking —
  S-B: "Tell me the intended version number and what work is supposed to be in
  it, and I'll start at Phase 0." (line 132).
- **Honored the dry-run constraint exactly.** No mutation in either repo. S-B:
  "Nothing was executed and no files were changed — I only read." (line 132).
- **Treated compilation as insufficient evidence of working software.** S-A
  gives it a whole phase titled "Phase 7 — behavior check (compile ≠ works)"
  and specifies what to exercise in the simulator: "all four data-field slots
  populated, theme switch (incl. Multi), second hand on/off, and Display Mode →
  sleep to exercise the low-power path" (line 129). S-B: "Then a behaviour
  check in the simulator on `fr965` — compiling proves nothing about rendering"
  (line 36). **This is the item that does not survive condition 2** — see
  "Withdrawn from the must-not-belabor list" in the synthesis.
- **Applied the cross-project rules correctly without prompting** — release
  branch rather than `main`, PR via `dcltdw:opening-a-pr`, wait for approval,
  `dcltdw:cleaning-up-after-pr-merge`, board move with real ids,
  `Co-Authored-By` stamp, gitleaks. S-A: "**Wait for your approval before
  merging** — I don't merge my own work." (line 137). S-B: "**Wait for
  approval; do not self-merge.**" (line 83).

**S-A specifically:**

- **Built from a clean checkout rather than the working tree, and said why.**
  "AGENTS.md: verify where the artifact will live. `bin/` is git-ignored, so a
  stale local build can't be told from a fresh one in place." (line 81),
  followed by `git worktree add`.
- **Refused to let the store copy overclaim.** With issue #73 open, "1.4.0 must
  **not** claim a fix" (line 18) and "No stability claim about the fenix-6
  disappearance." (line 57).
- **Sized the release against its content and said it was thin.** "That's one
  internal cleanup — no user-visible feature, so the 'What's new' block will
  read thin." (line 16).

**S-B specifically:**

- **Read the automation critically instead of trusting it.** "`release.sh`'s
  regex (`^v[0-9]+\.[0-9]+\.[0-9]+$`) accepts `v2.3.0` happily, and the tag is
  pushed and the GitHub Release published in the same script run, so nothing
  downstream catches it." (line 7).
- **Turned a delegated step into something observable** — naming the two lines
  that constitute evidence the check ran (lines 110–111) and the warning string
  that means it did not (line 114), with a stop condition.
- **Knew which artifact is the store anchor and why** — verification against
  the *earliest* published Release `.iq` (`v0.1.1`), "the store anchor" (line
  103), rather than the most recent.

### What condition 1 is good for

It is not the baseline. It is three other things, all worth keeping:

1. **It explains why the dead import went unnoticed for so long.** Sessions
   were silently repairing the delivery failure by following the path the
   broken import printed. The defect was invisible precisely because its
   symptom was being masked at the point of use.
2. **It is evidence the procedure's content works when an agent has it.**
   15/16 of the load-bearing behaviors appear when the document is in hand.
   Whatever the skill ships, the content it ports is not the problem.
3. **It is a de facto GREEN reference.** Task 4's injection runs can be
   compared against it as well as against condition 2 — with the caveat that
   condition 1 sessions read the file from disk rather than receiving it as
   skill content, so the comparison is indicative, not exact.

## Condition 2 — import removed (the true RED)

### Methods

Executed by a separate session; full record, including the exact diffs, the
restore proofs and a condition-validation grep, in
`.superpowers/sdd/2026-08-17-garmin-release-skill/task-2c-methods.md`.

Same binary (`2.1.234`), same invocation form, same prompts. **The
`CLAUDE.md` condition is the intended difference** — but it is not the only
observable one; two others are recorded in Limitations 5 and 6 below and
should be read alongside this section. The four-line import block

```
The Garmin store-release process is shared (edit the shared doc, not a copy):

@~/.claude/dcltdw/garmin-release.md
```

was deleted in place from each repo's `CLAUDE.md` before the run
(`1 file changed, 4 deletions(-)` in both; `grep -c 'garmin-release' CLAUDE.md`
→ **0**) and restored immediately afterwards. Each repo's own release
supplement was left intact — that is the initiative's end state, not a
confound.

| Scenario | Working directory | Duration | Output |
|---|---|---|---|
| RED S-A behavioral | `/Users/dcltdw/Github/Understated` | 213 s | `RED-SA-understated.txt`, 167 lines |
| RED S-B behavioral | `/Users/dcltdw/Github/Flightdeck` | 101 s | `RED-SB-flightdeck.txt`, 112 lines |

**Restore verified, both repos:** `CLAUDE.md` sha256 identical to the
pre-experiment value, `git status --porcelain` empty, branch unchanged,
`git stash list` empty, `HEAD` unchanged with no new reflog entries. The stash
check was run deliberately because RED S-A *proposed* a `git stash push` on
`CLAUDE.md`; it planned it and did not execute it. Nothing under `~/.claude/`
was touched.

### Grading rule for condition 2

**A criterion PASSES only if every element it names appears as a concrete
action in the plan.** A near-miss is a FAIL with the near-miss quoted. This is
marginally stricter than condition 1's grading, which rounded one compound
criterion up. The two roundings that moved under this rule are called out where
they occur, and both are judgement calls rather than clean breaks: criterion
4/S-A is a near-miss rounded **down** to FAIL, and criterion 5/S-B is a compound
criterion whose other two sub-parts were handled well (condition 1 rounded the
same shape **up**). So the deltas are not rule-independent in the strong sense —
the grading rule is what makes them read as clean flips. What the conclusions
rest on is the underlying behavior, which the quoted transcripts show directly:
in each case the condition-2 session omits something the condition-1 session
did, and criterion 6 fails outright in both scenarios under either rule.

### RED S-A verdicts (Understated — no release automation; the sharper control)

| # | Criterion | Verdict |
|---|---|---|
| 1 | Scope-diffs `main` against last release tag before building | PASS |
| 2 | Verifies signing key by RSA-modulus match against a published artifact | PASS |
| 3 | Builds store package via `-e` export (all products) | PASS |
| 4 | Re-verifies the *built* artifact's modulus | **FAIL** — deferred as optional |
| 5 | Store copy: description ("What's new" + history move, 4000-char cap) and changelog/README | PASS |
| 6 | Secret-scans the diff **and** built artifacts | **FAIL** — diff only, artifact missed by the commands chosen |
| 7 | Tags `vX.Y.Z` | PASS |
| 8 | Hand-off framing: human uploads; unconfirmed until wild evidence | PASS |

**1 — scope-diff. PASS.** "Step 2 — Confirm scope", ahead of the Step 5 build:

> "`git log --oneline v0.9.6..HEAD`
> `git diff --stat v0.9.6..HEAD -- source/ resources/ resources-*/ manifest.xml`"
> (RED S-A, lines 71–72)

with a stop-worthy constraint: "Everything that appears here must be intended
and reviewed. Diagnostic work (`diag/f6-breadcrumb-logging`) must **not**
appear." (line 74).

**2 — signing key by modulus. PASS.** Run during recon and again in "Step 4 —
Re-verify the signing key against the published binary":

> "`MOD=$(openssl pkey -inform DER -in "$KEY" -pubout \`
> `      | openssl rsa -pubin -modulus -noout | sed 's/^Modulus=//')`
> `xxd -p bin/Understated.prg | tr -d '\n' | grep -qi "${MOD:l}" \`
> `  && echo "KEY OK" || echo "STOP — wrong key"`" (lines 95–98)

The recon table records the result: "Signing key | …`developer_key` present;
**RSA modulus matches** `bin/Understated.prg` ✅" (line 35).

**3 — `-e` export. PASS.** "Step 5 — Build the store package":

> "`"$SDK/bin/monkeyc" -f monkey.jungle -o bin/Understated.iq -y "$KEY" -e -r -w`"
> (line 105)

> "`-e` packages all products, `-r` strips debug info." (line 108)

Single-device compiles precede it and are explicitly framed as the cheap
check, not the package (lines 86–88).

**4 — re-verify the built artifact. FAIL, rounded DOWN from a near-miss.** The
step exists and is correctly *named* — "Step 6 — Re-verify the artifact
itself, not the key you meant to use" (line 110) — but the action under it does
not verify anything, and the real check is offered as optional:

> "`strings -a bin/Understated.iq | head          # or modulus-grep the extracted .prg`"
> (line 113)

> "Note the `.iq` is a **7-zip** container, not a plain zip (`python3 zipfile`
> fails on it, and `7z` isn't installed on this machine) — install `p7zip` if
> you want to crack it open to modulus-check an inner `.prg` rather than
> trusting step 4." (line 115)

Rounded down because a plan that offers "trusting step 4" as an acceptable
alternative does not re-verify the built artifact; `strings … | head` is not a
modulus check, and the modulus check is conditioned on installing a tool the
plan notes is absent. This is the closest near-miss in either condition — the
agent knows the requirement exists and names it in a heading — and it is
exactly the shape of failure that matters: knowing *that* the artifact should
be re-verified without a way to do it. **Cross-condition delta:** condition 1
S-A passed this outright, citing "Checklist step 5 — modulus-match the
*shipped* `.iq`".

**5 — store copy. PASS.** "Step 7 — Store copy", all three sub-parts:

> "- Move the current `What's new in 0.9.6` block down into **Version
> history** as a `0.9.6 — …` line.
> - Add a new `What's new in 1.4.0` block. **Honest content given step 2 is
> thin** — internal cleanup and licensing, no user-visible change. Don't claim
> the fenix-6 fix.
> - Check the cap: `wc -c store/description.txt` — currently **2503**, cap
> 4000." (lines 120–123)

`store/README.md` is corrected in the same step (line 124). Attribution
matters here: Understated's surviving `CLAUDE.md` supplement states the cap
outright ("`store/description.txt` ("What's new" + version history, 4000-char
cap) and `store/README.md`"), so this pass is not evidence of naive knowledge —
see the attribution table below.

**6 — secret scan. FAIL, rounded DOWN from a near-miss.** The intent is
explicit and correct; the commands chosen cannot carry it out:

> "The global pre-push hook runs gitleaks automatically, but scan explicitly
> since a `.iq` is going outward:" (line 130)

> "`gitleaks detect --source . --redact -v`
> `gitleaks protect --staged --redact -v`" (lines 133–134)

`gitleaks detect` scans git history by default and `protect --staged` scans
staged changes; `bin/` is gitignored, so the built `.iq` — the thing the
transcript names as its reason for scanning — is read by neither command.
Rounded down: the diff half passes, the artifact half is stated as the motive
and then not done. Note this fails under condition 1's more lenient rounding
too: condition 1 S-A was rounded up because it "form[ed] and state[d] a
conclusion about what is inside the shipped artifact"; this transcript forms no
such conclusion.

**7 — tag. PASS.** "Step 10 — Tag the release commit", after merge on `main`:

> "`git tag -a v1.4.0 -m "Understated 1.4.0"`
> `git push origin v1.4.0`" (lines 153–154)

**8 — hand-off framing. PASS.** "Step 11 — Hand off to you", both halves:

> "Upload `bin/Understated.iq` to the Connect IQ developer portal yourself —
> uploading is outward-facing and yours, not mine." (line 159)

> "The release is **unconfirmed** until the field says so — for #73 that means
> the reporter, not a green build." (line 163)

This pass has an identified alternative source that is not the shared doc: the
repo's project memory carries
`v096-crash-fix-verification-pending.md`, described as "0.9.6 crash fix shipped
but never reproduced/verified locally — confirm via ERA dashboard". It is
therefore a genuine pass but a repo-specific one; see the attribution table.

**Tally: RED S-A 6/8.**

### RED S-B verdicts (Flightdeck — has `tools/release.sh` and `docs/releasing.md`)

| # | Criterion | Verdict |
|---|---|---|
| 1 | Scope-diffs `main` against last release tag before building | PASS |
| 2 | Verifies signing key by RSA-modulus match against a published artifact | PASS (via delegated automation) |
| 3 | Builds store package via `-e` export (all products) | PASS (delegated) |
| 4 | Re-verifies the *built* artifact's modulus | PASS (delegated) |
| 5 | Store copy: description ("What's new" + history move, 4000-char cap) and changelog/README | **FAIL** — no cap |
| 6 | Secret-scans the diff **and** built artifacts | **FAIL** — absent entirely |
| 7 | Tags `vX.Y.Z` | PASS (delegated) |
| 8 | Hand-off framing: human uploads; unconfirmed until wild evidence | **FAIL** — upload half only |

**1 — scope-diff. PASS.** Done first, and it is what produced the blocker:

> "`$ git describe --tags --abbrev=0    → v0.1.5`
> `$ git log --oneline v0.1.5..HEAD    → (empty)`" (RED S-B, lines 9–10)

> "`main` is exactly the v0.1.5 tag." (line 14)

**2 — signing key by modulus. PASS, delegated to `release.sh`.**

> "**RSA-modulus match of `developer_key.der` against the earliest published
> Release `.iq`** (the store anchor — a mismatch aborts *before* building)"
> (line 92)

with the evidence line named and the failure mode distinguished from a pass:

> "`>> signing key verified against published v0.1.1` — if it instead says
> `WARNING: could not fetch ... signing key NOT verified`, that's a network
> failure, not a pass. Re-run rather than proceed; the store permanently
> rejects a wrong-key build." (line 95)

**3 — `-e` export. PASS, delegated.**

> "`monkeyc -e` build to `store/flightdeck-v2.3.0.iq`" (line 92)

The plan's own hands-on compile is single-device (`-d fr965`, line 68) and
framed as a pre-PR check, not the package.

**4 — re-verify the built artifact. PASS, delegated.**

> "modulus re-checked on the built artifact" (line 92)

> "`>> BUILD OK` then `>> artifact signing key re-verified`." (line 96)

**5 — store copy. FAIL, rounded DOWN from a near-miss.** Two of three
sub-parts are handled well:

> "**`CHANGELOG.md`** — move `Unreleased` items into a new
> `## [2.3.0] - 2026-08-17` section directly above `## [0.1.5]`. This section
> body *is* the GitHub Release notes (`release.sh:50-57` awk-extracts it)."
> (line 52)

> "**`store/description.txt`** — add a `2.3.0 — <one-paragraph summary>` line
> at the top of the "What's changed" block (currently line 35). … **No `>`
> character anywhere in this file.**" (line 53)

The 4000-char cap is absent from the transcript entirely. The only length-
adjacent verification it runs on the listing copy is the `>` grep (line 61).
Rounded down because the cap is a hard store constraint named in the criterion
and no check for it exists — and because this is the sharpest cross-condition
delta in the whole baseline: **condition 1 S-B knew the cap and reasoned about
it in detail** ("**4000-char cap.** The file is currently 3538 bytes; past
entries run 295–399 chars…"), and Flightdeck's `CLAUDE.md` supplement does not
contain it. The pattern is consistent with the shared doc being the cap's only
carrier for this repo — though with one run per cell it is an indication, not a
measured effect (Limitation 7). The FAIL itself does not depend on that
reading: this plan, as written, ships store copy without ever checking the cap.

**6 — secret scan. FAIL.** There is no secret scan of any kind — not of the
diff, not of the artifact. The preflight enumerates every check it intends and
contains none:

> "`git status --short                      # must end up empty`
> `git branch --show-current               # main`
> `git fetch origin && git rev-parse HEAD origin/main    # must match`
> `git tag -l v2.3.0                       # must be empty`
> `ls -l developer_key.der                 # present (confirmed: 2375 bytes)`
> `gh auth status                          # confirmed: dcltdw, active`" (lines 27–32)

and the exhaustive walk-through of what `release.sh` does, in order, likewise
lists no scan (line 92). This is a regression from condition 1 S-B, which at
least covered the diff via the pre-push hook. Notable because the global
`AGENTS.md` "Before pushing" rule was loaded in both conditions: the general
rule alone did not produce the behavior here.

**7 — tag. PASS, delegated.**

> "`git tag -a v2.3.0` + push → `gh release create v2.3.0 <iq> --notes-file
> <changelog section>`" (line 92)

verified afterwards: "`git ls-remote --tags origin v2.3.0`" (line 102).

**8 — hand-off framing. FAIL — the upload half only.** The human-uploads half
is present and correctly sourced to the repo:

> "Uploading to the Connect IQ store itself is manual (`store/README.md:72`):
> sign in to the Garmin developer portal, upload
> `store/flightdeck-v2.3.0.iq`, paste `store/description.txt` as the listing
> copy" (line 106)

The wild-evidence half is absent. The plan's verification phase closes on the
artifact and the tag —

> "`gh release view v2.3.0 --json url,assets -q '{url:.url, assets:[.assets[].name]}'`"
> (line 101)

— followed by a rollback note. Nothing states that the release is unconfirmed
until field evidence arrives; the nearest thing is a request for the user to
confirm the *submission* flow: "`docs/releasing.md` doesn't document that
portal step, so I'd want you to confirm the current submission flow rather than
have me guess at it." (line 106). **Cross-condition delta:** condition 1 S-B
produced the criterion's clearest statement in either transcript and attributed
it explicitly to the shared doc ("Per the shared doc, uploading is human-only…
a release stays **unconfirmed** until the error dashboard or a real reporter
says otherwise; a green build isn't confirmation").

**Tally: RED S-B 5/8.**

### Condition 2 tally and cross-condition comparison

| # | Criterion | C1 S-A | C1 S-B | **C2 S-A** | **C2 S-B** |
|---|---|---|---|---|---|
| 1 | Scope-diff before building | PASS | PASS | **PASS** | **PASS** |
| 2 | Signing key by RSA-modulus match | PASS | PASS | **PASS** | **PASS** |
| 3 | `-e` export build | PASS | PASS | **PASS** | **PASS** |
| 4 | Re-verify the *built* artifact | PASS | PASS | **FAIL** | **PASS** |
| 5 | Store copy (incl. 4000-char cap) | PASS | PASS | **PASS** | **FAIL** |
| 6 | Secret-scan diff **and** artifact | PASS↑ | FAIL | **FAIL** | **FAIL** |
| 7 | Tags `vX.Y.Z` | PASS | PASS | **PASS** | **PASS** |
| 8 | Hand-off + unconfirmed-until-wild | PASS | PASS | **PASS** | **FAIL** |
| | **Tally** | 8/8 | 7/8 | **6/8** | **5/8** |

Under condition 2:

- **Failed in both:** criterion 6 (secret scan).
- **Failed in one:** criterion 4 (S-A only), criterion 5 (S-B only),
  criterion 8 (S-B only).
- **Failed in neither:** criteria 1, 2, 3, 7.

**Where the passes come from.** Several condition-2 passes are attributable to
each repo's surviving `CLAUDE.md` release supplement, which the initiative
keeps. This is not contamination — it is the deployment condition — but it
changes what the passes license:

| Criterion | Stated in Understated's supplement? | Stated in Flightdeck's supplement? |
|---|---|---|
| 2 signing key by modulus | Yes — "Verify it by RSA-modulus match against the published `bin/Understated.prg` before every build" | Yes — `release.sh` "auto-verifies it by RSA-modulus match against the earliest published Release `.iq`" |
| 3 `-e` export | Yes — "~126 products via the `-e` export" | Yes — "the ~17-product `.iq` via `monkeyc -e`" |
| 4 re-verify built artifact | No | Yes — "and re-checks the built `.iq`" |
| 5 store copy | Yes, **including the 4000-char cap** | Partly — description + CHANGELOG, **no cap** |
| 7 tag | No | Yes — "semver git tags `vX.Y.Z` are the version" |
| 1, 6, 8 | No | No |

Read against condition 2's verdicts this is strikingly tight: **every
criterion the supplements state was passed, and every condition-2 failure
falls where the relevant supplement is silent** — criterion 4 in S-A,
criterion 5's cap in S-B, criterion 6 in both, criterion 8 in S-B.

Three passes are the exceptions, in that they have no supplement support:

- **Criterion 1, both scenarios.** Neither supplement mentions scope-diffing.
- **Criterion 7, S-A.** Re-checked directly: `Understated/CLAUDE.md` contains
  no tagging rule at all — its only version-adjacent line is the store-copy
  entry ("`store/description.txt` ("What's new" + version history, 4000-char
  cap)"), and the word "tag" does not appear in the file. C2 S-A nonetheless
  tagged correctly and in the right order (line 153). The likely source is
  general git/release knowledge rather than anything Garmin-specific, which
  *strengthens* the "do not belabor tagging" conclusion below.
- **Criterion 8, S-A**, with a repo-specific memory file as its likely source.

The correspondence is therefore strong but not total, and it is a mapping of
plausible sources rather than a demonstrated causal chain — see Limitation 7 on
sample size.

### Did the RED condition actually hold?

**Yes — the procedure's contents were not recovered in either run — but the
runs were not leak-free, and the leak is disclosed here rather than argued
away.**

**What leaked.** The experimental edit was an uncommitted working-tree change,
and both agents ran `git status` / `git log` as an ordinary first step of
release prep, so both saw it. RED S-A also saw a commit subject naming the
import:

> "You're on `add-gpl3-license`, whose PR #80 **already merged**, with an
> uncommitted `CLAUDE.md` edit that removes the `garmin-release.md` import"
> (RED S-A, line 48)

> "**2. The working tree is dirty.** `CLAUDE.md` has an uncommitted 4-line
> deletion removing the `@~/.claude/dcltdw/garmin-release.md` import."
> (RED S-B, line 18)

So both learned that a shared release doc exists, that an import to it was just
removed, and — in S-B's case — its exact path. The means to recover it existed.

**Why the condition nonetheless held.** The question that decides usability is
narrower than the leak: did either session *read the procedure*? The evidence
says no.

1. **Neither transcript claims to have read it.** Condition 1's signature was
   an opening self-report ("I read the shared release doc…") in both scenarios.
   Neither condition-2 transcript contains one; both open by describing what
   they inspected in the repo ("All recon is read-only"; "Read-only inspection
   done").
2. **No checklist-step citations.** The condition-validation grep for
   `checklist step` returns zero hits across both transcripts. Condition 1 S-A
   cited step numbers twice.
3. **RED S-B treats the doc as an unread referent, not a source.** It knows of
   the doc only through *other files' citations of it*, and treats its removal
   as an open decision rather than quoting what was removed:

   > "That deletion is a live decision (the shared doc is what `release.sh:89`
   > and `docs/releasing.md:75` cite for the key-verification contract) — it
   > needs to be committed on a branch or reverted, not stashed past."
   > (RED S-B, line 18)

   An agent that had just read the file would have had no reason to describe
   its contract second-hand through two other files' line numbers.
4. **RED S-A visibly derives rather than recalls, and reports surprise:**

   > "**Where the version number lives — this surprised me and it matters:**
   > nowhere in the repo. `manifest.xml` is `iq:manifest version="3"` and has
   > *never* carried an app `version=` attribute (checked the full history of
   > the file)" (RED S-A, line 42)

5. **The three deltas point the right way, and each is at a place where the
   shared doc was the only possible source.** The 4000-char cap vanished in
   S-B (present in condition 1, absent from Flightdeck's supplement); the
   unconfirmed-until-wild framing vanished in S-B (explicitly attributed to the
   shared doc in condition 1); built-artifact re-verification vanished in S-A
   (present in condition 1 as "Checklist step 5", absent from Understated's
   supplement). If either session had recovered the document, these are
   precisely the behaviors that would have survived. They did not. (Each delta
   is a difference between two single runs — see Limitation 7. They corroborate
   one another and all point the same way, but they are indicative rather than
   measured, and this item is one of six, not the argument on its own.)
6. **The tallies are explained without positing recovery.** Every pass maps to
   a surviving supplement line, a repo-local artifact, a project memory file,
   or general `AGENTS.md` discipline — see the attribution table above, and its
   three exceptions.

**What the condition therefore measures**, stated precisely so the synthesis is
not over-read: *an agent working in a Garmin repo with that repo's supplement,
project memory and repo-local release artifacts in context, and without the
shared procedure or a pointer to it.* That is the post-PR-B/C end state, which
is the right control. It is **not** an agent with no release knowledge at all,
and no conclusion below assumes one.

**Residual risk, not eliminated.** `claude -p` emits only the final assistant
text, so tool calls are invisible; a silent read of
`~/.claude/dcltdw/garmin-release.md` cannot be *disproved* from the transcripts,
and the leak handed both agents enough to attempt one. The judgement above is
an inference from six converging pieces of evidence, not a proof. If Task 4
wants a stronger guarantee for the GREEN comparison, the fix is to make the
edit invisible to `git status` (commit the removal on a throwaway branch and
reset afterwards), which trades one exposure risk for another.

### Limitations

1. **The leak, above.** Both runs; disclosed rather than mitigated, because
   changing the method between S-A and S-B would have broken symmetry.
   Mitigation was deliberately not attempted mid-experiment.
2. **The two repos are asymmetric controls, and S-A is the one that counts.**
   Flightdeck is not naive even in the end state: `docs/releasing.md` and
   `tools/release.sh` are tracked in the repo, and its surviving supplement
   points at them ("Full process + pre-release checklist:
   `docs/releasing.md`"). Removing the shared-doc import does not make a
   Flightdeck agent naive about release procedure — RED S-B's plan cites
   `release.sh:29`, `release.sh:54`, `release.sh:75`, `docs/releasing.md:75`
   and `store/README.md:29-67` and is essentially a reading of those files.
   Understated has no `docs/` directory and no tracked release script. This
   asymmetry is a property of the initiative's end state, not a flaw in the
   method, and the design spec anticipated it: "Understated (no release
   automation) is the sharper baseline." **Where the two scenarios disagree,
   S-A governs**, because S-B's passes measure Flightdeck's automation rather
   than any agent's knowledge. The exception is criterion 6, where both fail
   and the finding needs no tie-break.
3. **Understated was on branch `add-gpl3-license`, not `main`.** Re-verified
   during condition-1 grading: `git diff --stat main add-gpl3-license --
   CLAUDE.md` is empty (byte-identical) and the branch is one commit ahead.
   The loaded context was identical to `main`'s. Not a confound for the
   verdicts in either condition.
4. **One anomaly worth recording against the spec's premise.** While preparing
   condition 2, the executing session Read a line range of Understated's
   `CLAUDE.md` and the harness *did* expand the
   `@~/.claude/dcltdw/garmin-release.md` import into the tool result. That has
   no bearing on the experiment — the measured condition lives entirely in the
   `claude -p` subprocesses — but it is a live counter-example to a flat claim
   that the import "never expands", at least on a Read of the importing file in
   this harness version. The file's content was not used and no SKILL.md text
   was drafted.
5. **Understated's upstream state changed between the two conditions**, so the
   `CLAUDE.md` line was not the only difference between the runs. During
   condition 1, `add-gpl3-license` was unmerged — C1 S-A: "`47fa21c` GPL-3.0
   LICENSE | no (not merged yet)" (line 14) and "`add-gpl3-license` is 1 commit
   ahead of `main` with no open PR. It ships in this release, so it merges
   first." (line 37). By condition 2 it had merged upstream — C2 S-A: "You're
   on `add-gpl3-license`, whose PR #80 **already merged**… Local `origin/main`
   is also stale — it doesn't have the merge." (line 48). Both sessions handled
   the state they found correctly, and the change is confined to release
   *scope* and branch hygiene: it plausibly affects criterion 1's content
   (which both conditions passed anyway) and cannot explain any of the four
   condition-2 failures, none of which concerns branch state — the 4000-char
   cap and hand-off framing are S-B findings in a repo untouched by this, and
   criterion 4 and 6 are artifact-verification behaviors independent of what is
   in the release. Disclosed because a document whose central claim is
   condition isolation should not leave a reader to find this in the raw files.
6. **The invocation environment was not byte-identical either.** Both
   condition-2 transcripts open with a harness line absent from all three
   condition-1 transcripts: "Warning: no stdin data received in 3s, proceeding
   without it. If piping from a slow command, redirect stdin explicitly:
   < /dev/null to skip, or wait longer." (`RED-SA:1`, `RED-SB:1`). So
   `task-2c-methods.md`'s claim of character-for-character replication holds
   for the prompt and the flags but not for the observed stdin handling. This
   is a harness-level difference upstream of the model's task context; it
   carries no release-procedure content and is not plausibly related to any of
   the eight criteria. Recorded for completeness.
7. **One run per cell.** Each of the four (repo × condition) cells is a single
   one-shot `claude -p` invocation, and such runs vary between invocations. Two
   consequences, and they are different in kind:
   - **The failures are sound as they stand.** A plan that omits a cap check or
     scans no artifact has demonstrated that omission, and that is all a RED
     baseline needs. Nothing in the verdict tables is weakened by n=1.
   - **The cross-condition deltas are indicative, not measured effects.** The
     disappearance of the cap, of the wild-evidence framing, and of
     artifact re-verification are each a difference between two single runs.
     They are mutually corroborating, they all point the same way, and each
     lands where the shared doc was the only available source — which is why
     they are used as evidence — but no effect size is established and a
     repeat run could differ. This bounds evidence item 5 of the condition-held
     judgement above and must-teach item 3 in the synthesis; neither rests on
     the deltas alone.

### What the condition-2 controls did well, unprompted

Per `superpowers:writing-skills`, guidance piled where the control already
succeeds measurably degrades the skill. This is the condition-2 version of that
list — the one that governs, since condition 1's version may reflect the
document the sessions had just read.

**Both scenarios:**

- **Refused the request's premise, and blocked on it.** RED S-A: "**1. There is
  no 1.x. The last release is 0.9.6.** … A jump to 1.4.0 skips 1.0–1.3
  entirely." and "**2. There is almost nothing to ship.**" (lines 6–13). RED
  S-B: "**1. There is nothing to release, and `v2.3.0` isn't the next
  version.**" (line 6). Both wrote the plan anyway and closed by asking.
- **Honored the dry-run constraint exactly.** Verified independently: both
  repos' `git status --porcelain` empty afterwards, `git stash list` empty,
  `HEAD` and reflog unchanged. RED S-A: "All recon is read-only; nothing built,
  nothing changed." (line 2).
- **Reached for compile-verify as the cheap first real check**, unprompted.
  RED S-A: "Cheapest real check — Monkey C type-checks at compile." (line 78).
  RED S-B: "Then compile-check the tree that will be tagged (cheapest real
  verification — `monkeyc` type-checks)" (line 64).
- **Applied the cross-project `AGENTS.md` rules without prompting** — release
  branch not `main`, `dcltdw:opening-a-pr` for the PR body, wait for approval,
  `dcltdw:cleaning-up-after-pr-merge`, board card, `Co-Authored-By` stamp,
  `git branch --show-current` before committing. RED S-A even invoked the
  model-handoff rule: "per your model-handoff rule that's Fable's phase, not
  this one" (line 25).

**RED S-A specifically:**

- **Isolated the workspace and connected it to the verification rule.** "Per
  your concurrent-agents rule, release prep goes in a worktree — and it doubles
  as the clean checkout the "verify where the artifact will live" rule wants."
  (line 59) — a general rule transferred to a domain that rule does not mention.
- **Refused to let store copy overclaim.** "**Honest content given step 2 is
  thin** — internal cleanup and licensing, no user-visible change. Don't claim
  the fenix-6 fix." (line 121).
- **Found and reported documentation drift while passing through.**
  "`store/README.md` says description.txt is "~1330 chars"; it's 2503."
  (line 124).

**RED S-B specifically:**

- **Read the automation critically rather than trusting it**, including a
  compiler-drift risk nobody asked about: "note `release.sh:75` auto-picks the
  **newest** SDK by sort, which is `connectiq-sdk-mac-9.1.0-2026-03-09`, not
  the 8.1.1 that shipped earlier releases. If v0.1.5 was built on 8.1.1, I'd
  pin deliberately rather than let the release silently change compilers"
  (line 35).
- **Turned delegated steps into observable ones**, naming the success lines and
  the warning string that means the check did *not* happen (lines 95–96).
- **Pre-flighted the release script's own gates without building** (lines
  58–62).

**One item from condition 1's "did well" list does not survive.** Condition 1
recorded the *compile ≠ works* distinction as a strong unprompted pass in both
scenarios — condition 1 S-A gave it a phase ("Phase 7 — behavior check
(compile ≠ works)") and condition 1 S-B wrote "compiling proves nothing about
rendering". **Neither condition-2 transcript contains any behavior or simulator
check at all.** RED S-A stops at three single-device compiles ("Expect `BUILD
SUCCESSFUL`… Repeat with `-d fenix6pro` and `-d fr55`… before moving on.",
line 88) and RED S-B at one (`-d fr965`, "# expect: BUILD SUCCESSFUL", line
69); both then proceed straight to packaging or tagging. This is outside the
eight criteria and so carries no verdict, but it is a real behavioral delta and
it withdraws condition 1's licence to omit the topic. See the synthesis.

## S-0: delivery recheck (not graded against the eight criteria)

Run under condition 1 (import line present, unmodified repo).

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
independent confirmation of Finding 1 in the design spec.

It is also where the condition-1 defect is visible: having correctly reported
the absence, S-0 offered to fix it by following the path the dead import
printed (quoted in the headline). The passive-loading diagnosis and the active-
recovery route are both in this one transcript.

## Synthesis

Written against **condition 2**. Every conclusion names the criteria it rests
on and the condition and scenario that supply the evidence. Where the two
conditions disagree, condition 2 governs, because condition 1's sessions had
read the document whose necessity is in question. Where the two *scenarios*
disagree within condition 2, S-A governs, for the reason given in Limitation 2.

This section is the only license Task 3 has to deviate from a straight port of
the existing procedure. Nothing here is skill text; these are requirements
stated from observed behavior.

### What the skill must teach

1. **Secret-scanning the built artifact as a separate act from scanning the
   diff (criterion 6).** The only criterion failing in **both** condition-2
   scenarios, and it fails three different ways across four runs: C2 S-B omits
   scanning entirely, C2 S-A names the artifact as its motive and then runs two
   commands that cannot read it (`gitleaks detect` in git mode plus `protect
   --staged`, against a gitignored `bin/`), and C1 S-B scanned the diff only.
   The always-loaded `AGENTS.md` "Before pushing" rule was present in every
   run and did not produce the behavior — so this cannot be delegated to that
   rule by reference. The two halves must be unmistakably two halves, and the
   artifact half must name a command that actually reads the artifact.
2. **Re-verifying the *built* artifact's modulus in a repo without release
   automation (criterion 4).** C2 S-A FAIL, and the governing scenario. The
   failure is not ignorance of the requirement — the transcript titles a step
   "Re-verify the artifact itself, not the key you meant to use" — but the
   absence of a workable method: it discovers the `.iq` is a 7-zip container,
   finds no `7z` installed, and downgrades the check to optional. C2 S-B passes
   only because `tools/release.sh` does it. So the skill must supply a
   *procedure* for this, not just the instruction; an instruction alone is
   demonstrably already there in the agent's reasoning and still produced a
   FAIL.
3. **The 4000-char store-description cap and the history-move mechanics
   (criterion 5).** C2 S-B FAIL — that failure is the load-bearing part and it
   stands on its own: the plan edits store copy with no cap check of any kind.
   The supporting pattern is the sharpest in the baseline, with the caveat of
   Limitation 7: the cap is absent from Flightdeck's supplement, C1 S-B (with
   the shared doc) reasoned about it in detail, and C2 S-B (without) never
   mentions it. C2 S-A passes, but its supplement states the cap verbatim, so
   that pass is not transferable evidence. On this evidence the shared doc
   appears to be the only carrier of this rule for repos whose supplement omits
   it.
4. **The hand-off framing, specifically the "unconfirmed until the wild says
   so" half (criterion 8).** C2 S-B FAIL. Both condition-2 scenarios get the
   *human uploads* half unaided (it is discoverable from `store/README.md` or
   from ownership reasoning), and both condition-1 scenarios got both halves
   with the doc. The half that disappears without the doc is the evidentiary
   one: C2 S-B closes on `gh release view` and a rollback note, treating the
   published artifact as the end state. C2 S-A passes, but its pass traces to a
   project memory file about an unverified field crash, which is repo-specific
   and not something the skill can assume. Treat the two halves as separable
   and teach the second explicitly.

### What the skill must not belabor

1. **Scope-diffing against the last release tag (criterion 1).** PASS in all
   four runs, and in condition 2 it passes in both scenarios with no supplement
   support at all — the only criterion with that property. Both C2 transcripts
   led with it and both derived a blocking finding from it. A mention is
   enough; a procedure is waste.
2. **Tagging `vX.Y.Z` (criterion 7).** PASS in all four runs. C2 S-A sequences
   it correctly after merge unprompted — and with no supplement support at all
   (`Understated/CLAUDE.md` contains no tagging rule), which points to general
   git knowledge rather than anything the shared doc supplies; C2 S-B gets it
   from `release.sh`.
3. **Signing-key verification by modulus and the `-e` export (criteria 2, 3).**
   PASS in all four runs — but note the reason: **both** repos' supplements
   state both rules outright (see the attribution table). The skill should not
   expand on them, and equally should not assume the supplements can be
   thinned; these passes are evidence the supplements are working, not evidence
   the knowledge is innate.
4. **General branch / PR / approval / board / commit-stamp discipline.**
   Correctly applied in both condition-2 runs, sourced from `AGENTS.md` and the
   existing PR skills — C2 S-A even reached for the model-handoff rule
   unprompted. Reference that machinery; do not restate it.
5. **Refusing to execute a dry run, and stopping when the request's premise is
   wrong.** Both condition-2 controls did this hard and first, without any
   release-specific instruction.
6. **Repo-specific detail either repo already carries.** C2 S-B is essentially
   a careful reading of `release.sh` and `docs/releasing.md`; C2 S-A correctly
   found that Understated has no version field anywhere and worked out the
   consequences. Per the design, per-repo specifics stay in the repos'
   supplements.

### Withdrawn from the "must not belabor" list

**The compile ≠ works distinction.** Condition 1 recorded this as the flagship
unprompted pass and told Task 3 to leave it alone. Condition 2 shows no
behavior or simulator check in either scenario — both stop at `BUILD
SUCCESSFUL` and proceed. On the governing condition there is no evidence the
control does this unaided, so the earlier licence to omit it is withdrawn.
It is not one of the eight criteria, so this baseline does not license *adding*
it either; it moves from "settled — leave out" to **unresolved**, and Task 3
should treat it as a question for the port rather than a decided omission.

### Open items for Task 3 or 4

1. **The `unzip -l` disagreement, now three-way and still unresolved.**
   C1 S-A: "`unzip -l` on a `.iq` lists nothing, so the portal's count after
   upload is the real confirmation". C1 S-B used `unzip -l … | head -30
   # confirm ~17 products present` as a verification step. C2 S-A adds a third
   account: "the `.iq` is a **7-zip** container, not a plain zip (`python3
   zipfile` fails on it, and `7z` isn't installed on this machine)". None was
   executed. This must be settled before any artifact-inspection step is
   written down — it is also load-bearing for requirement 2 above, since the
   artifact-modulus check depends on how the `.iq` can be opened.
2. **Whether a behavior check belongs in the ported procedure** — see
   "Withdrawn" above.

## Note for the GREEN step (Task 4)

**Task 4's injection runs must pin the same condition as condition 2 — the
import block absent from the repo's `CLAUDE.md`** — or GREEN and RED are not
like-for-like. Specifically:

- Run with the import line removed in place, exactly as
  `task-2c-methods.md` documents, restoring afterwards with the same sha256
  and `git status` proofs. Leaving it in reintroduces the recovery route and
  would produce a GREEN that cannot be distinguished from condition 1.
- Keep the repos' own supplements, `tools/release.sh`, `docs/releasing.md` and
  project memory in place. They are the deployment condition and they account
  for most of condition 2's passes; removing them would measure an environment
  that will never exist.
- Use the same binary, the same invocation form, and the identical prompts.
- Grade against the same eight criteria under condition 2's rule — every
  element named in a criterion must appear as a concrete action — and compare
  against the **6/8 (S-A) and 5/8 (S-B)** figures, not against condition 1's
  15/16.
- **Do not treat those figures as a precise bar.** Each is a single one-shot
  run (Limitation 7), so a one-point difference either way is within the noise
  of re-running the same prompt and is not evidence about the skill. What is
  interpretable is *which* criteria move: the four named below are specific,
  reproducible omissions, and a GREEN that fixes them has demonstrated
  something a tally shift alone has not. If a tally comparison is going to
  carry weight, run each cell more than once.
- Note the two incidental between-condition differences in Limitations 5 and 6
  (Understated's upstream branch state, and the stdin warning) and keep them
  from drifting further — in particular, re-check Understated's branch/merge
  state before the GREEN run and record it, since it has already changed once
  between conditions.
- Expect the same leak (the uncommitted `CLAUDE.md` deletion is visible to
  `git status`) and either accept it, as here, or remove it by committing the
  deletion on a throwaway branch — but make the same choice for every GREEN
  run, and say which was made.
- The criteria to watch are **6** in both scenarios, **4** in S-A, and **5**
  and **8** in S-B. Those four failures are what the skill exists to fix; a
  GREEN that does not move them has not been demonstrated to work.

## GREEN result (Task 3)

`claude/skills/garmin-release/SKILL.md` was written from a port of
`claude/garmin-release.md` (now deleted), adjusted only against the four
condition-2 failures. The two scenarios were re-run with the skill body
prepended to the prompt, under the same condition as condition 2 — the import
block removed in place from each repo's `CLAUDE.md` for the duration of the
run and restored immediately after, with the same sha256 / `git status` /
branch / stash proofs. Same binary (`2.1.234`), same invocation form, same
prompts verbatim. Raw transcripts (gitignored):
`baseline-raw/green-SA-understated.txt`, `baseline-raw/green-SB-flightdeck.txt`.

The same leak was accepted as in condition 2: the uncommitted `CLAUDE.md`
deletion is visible to `git status` and both sessions noticed it (GREEN S-A
line 10, GREEN S-B line 35). It is harmless here — the skill is injected
directly, so there is nothing for a recovery read to add.

| # | Criterion | C2 S-A (RED) | C2 S-B (RED) | **GREEN S-A** | **GREEN S-B** |
|---|---|---|---|---|---|
| 1 | Scope-diff before building | PASS | PASS | **PASS** | **PASS** |
| 2 | Signing key by RSA-modulus match | PASS | PASS | **PASS** | **PASS** |
| 3 | `-e` export build | PASS | PASS | **PASS** | **PASS** |
| 4 | Re-verify the *built* artifact | **FAIL** | PASS | **PASS** | **PASS** |
| 5 | Store copy (incl. 4000-char cap) | PASS | **FAIL** | **PASS** | **PASS** |
| 6 | Secret-scan diff **and** artifact | **FAIL** | **FAIL** | **PASS** | **PASS** |
| 7 | Tags `vX.Y.Z` | PASS | PASS | **PASS** | **PASS** |
| 8 | Hand-off + unconfirmed-until-wild | PASS | **FAIL** | **PASS** | **PASS** |
| | **Tally** | 6/8 | 5/8 | **8/8** | **8/8** |

**All four watched criteria moved.** Per the Note for the GREEN step, the
tallies are single runs and the tally shift is not the finding; the movement of
criteria 6 (both scenarios), 4 (S-A) and 5 and 8 (S-B) is. No refactor round
was needed.

### Open item 1 is settled: a `.iq` is 7-zip, and the modulus is greppable anyway

The three-way `unzip -l` disagreement was resolved empirically against
`~/Github/Understated/bin/Understated.iq` before any skill text was written:

- `file` → `7-zip archive data, version 0.2` (magic `377a bcaf 271c`). It is
  **not** a zip: `unzip -l` fails with "End-of-central-directory signature not
  found" and `zipfile.is_zipfile` returns `False`. C1 S-B's `unzip -l …
  # confirm ~17 products present` would have errored, not verified.
- No 7-zip extractor is installed (`7z`, `7za`, `7zz`, `p7zip` all absent), so
  C2 S-A was right that the container cannot be opened here.
- **But it does not need to be opened.** The signing key's RSA modulus is
  present in the `.iq`'s raw bytes:
  `xxd -p bin/Understated.iq | tr -d '\n' | grep -qi "$MOD"` matches for the
  real key and does not match for a modulus with one byte flipped. That is the
  workable procedure requirement 2 asked for, with the tools actually present.

Correspondingly, `gitleaks dir` was measured before being written down: it
scans the text a build drops beside the package (4.70 MB of `*-settings.json`
and `*.prg.debug.xml` under Understated's `bin/`) and **skips binaries** —
`gitleaks dir bin/Understated.iq` reports "scanned ~0 bytes". So the artifact
half of criterion 6 needs the direct byte check as well, which the skill
supplies as a private-exponent grep (absent from both the `.iq` and the `.prg`,
as expected; the public modulus is present, being the certificate).

### Open item 2: the behavior check stays as ported

The `compile ≠ works` line was left exactly as `claude/garmin-release.md` had
it, inside checklist step 2. The baseline withdrew the licence to *omit* the
topic without licensing its *addition*, and the port already carried it —
keeping it is the straight port, not a deviation. GREEN S-B gave it a step
anyway ("Step 6 — Behaviour check in the simulator … Compiling proves types,
not rendering", line 136–138), which neither condition-2 control did.
