# Classification pin — design

Date: 2026-08-19. Approved in-chat (brainstorming session; all three
contested points ratified by dcltdw). Tracked as dcltdw/agents#16.

## Problem

The brainstorming skill has every session classify a task as spike /
bounded / architectural. Bounded means no spec file and no plan document —
and AGENTS.md's phase boundary (design → execution, Fable → Opus) is
anchored to the plan file: "the moment `docs/superpowers/plans/<name>.md`
is written, that turn is over." A session that (mis)classifies a task as
bounded therefore does not just skip the spec — it guarantees the
anchoring artifact never exists, making handoff event 1 unfireable.

Observed 2026-08-19 in the #13 session: the task-start protocol change
(doctrine file + skill + fleet-wide implications) was labeled bounded, and
the session slid from design approval straight into implementation with no
spec, no plan, and no handoff. The skill's own red flag ("reaching for a
label to skip work IS the doubt") fired and was argued past — the existing
pattern: anything arguable gets argued away. The artifact anchor was
defeated one level upstream, at the arguable decision that determines
whether the artifact ever gets created.

## Decision 1: a path-based pin over the whole `claude/` tree

New section in `claude/AGENTS.md`, placed immediately after "Model
handoffs at phase boundaries" — it exists to protect that section's
anchor, and adjacency is the argument. The rule text (normative; the
implementation copies it verbatim, adjusting only if the surrounding
file's voice demands it):

> ## Classification pin: doctrine takes the architectural path
>
> The brainstorming skill has every session classify a task as spike /
> bounded / architectural. One classification is not the session's to
> make:
>
> **Any diff touching the agents repo's `claude/` tree takes the
> architectural path — spec, then plan — regardless of apparent size.**
> "It's just a small doctrine edit" is not a classification argument; the
> diff paths are the classification. Everything under `claude/` deploys
> machine-globally — AGENTS.md, the skills, the pre-push hook, the plugin
> manifest — so a mis-sized change there lands in every repo at once. And
> a "bounded" label doesn't merely skip the spec: bounded means no plan
> file is ever written, which deletes the artifact handoff event 1 is
> anchored to. That is how a session slid from design approval straight
> into implementation with no spec, no plan, and no handoff — the
> artifact anchor was defeated upstream, at the arguable decision that
> determines whether the artifact ever exists. A path can't be argued
> with.
>
> **One carve-out, granted only by dcltdw.** A genuinely mechanical
> edit — a typo, a broken link — may take the bounded path only when
> dcltdw explicitly grants that for the specific change, in response to
> an ask. The grant is in the transcript or it isn't; the session never
> self-classifies into the carve-out. Same shape as board discovery:
> stop and ask.

Whole tree rather than the issue's proposed two paths (`claude/AGENTS.md`
plus `claude/skills/`), ratified 2026-08-19: everything under `claude/`
ships machine-globally via `install.sh` — `githooks/pre-push` is
executable doctrine that runs on every push, `plugin.json` is the manifest
consuming machines install, `ADOPTING.md` is how new machines get wired.
One prefix, nothing to maintain, and no gap to remember when a new
doctrine surface appears under `claude/`.

## Decision 2: no general "bounded" floor

Ratified 2026-08-19: the pin is path-based and nothing more. A general
floor needs words like "single-file scale" or "when in doubt" — exactly
the arguable vocabulary the #13 session argued past. The brainstorming
skill already says "when in doubt, take the heavier path" and that failed;
restating it in AGENTS.md would add prose, not enforcement. File count
does not track the risk anyway — the #13 failure began as a one-file
doctrine edit.

## Decision 3: the carve-out is human-granted, never self-classified

Ratified 2026-08-19. A rule that demands a spec and a plan for a broken
link invites the quiet noncompliance that erodes pins, so a carve-out
exists — but "trivial" is precisely the arguable word the pin eliminates,
so the session never decides it. The carve-out applies only when dcltdw
explicitly grants it for the specific change, in the transcript, in
response to an ask. Granted, the change takes the bounded path — which
still carries the brainstorming skill's in-chat design and approval gate.
No grant (silence, ambiguity, a general "sure, clean things up") means
architectural. Checkable the same way the pin is: the grant is present or
it is not.

## Enforcement: instruction rank, not skill edits

The brainstorming skill is upstream third-party (the superpowers plugin);
it is not forked or edited. The pin works because user instructions
outrank skills — `using-superpowers` states it, and the skill's own
classification step is explicitly overridable by the human partner. The
pin in AGENTS.md is that override, made standing. Once the architectural
path is forced, existing machinery does the rest: spec, then plan file,
then handoff event 1 fires and the model boundary happens on its own. No
new events, no new tooling.

## Out of scope

- **Fleet-wide pins on other repos' doctrine** (their `CLAUDE.md` files) —
  ratified 2026-08-19: repo-local blast radius, and forcing spec + plan on
  a one-line build-command note is ceremony without payoff.
- **Edits to the superpowers plugin or the dcltdw skills** — enforcement
  is by instruction rank (above).
- **#10** (model tiers for subagent seats within an execution session) —
  shares only the family resemblance of closing arguable-judgment gaps.

## Operational impact

The diff is `claude/AGENTS.md` only. No skill changes, so no plugin
version bump and no reinstall on consuming machines. The rule goes live
when the primary clone updates (the `~/.claude/dcltdw` symlink points into
it).

## Verification

- Re-read the rendered AGENTS.md section against this spec's rule text
  after landing.
- Self-application check: the change that lands this rule itself touches
  `claude/`, so it must itself arrive via spec → plan. This spec and the
  plan that follows it are the rule's first compliance test — a PR landing
  the pin without both artifacts refutes itself.
