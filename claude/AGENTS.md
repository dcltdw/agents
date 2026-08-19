# Universal collaboration rules

Canonical cross-project rules for working with Claude on any of dcltdw's repos.
Imported machine-globally via `@~/.claude/dcltdw/AGENTS.md` (see [ADOPTING.md](ADOPTING.md)). Domain- and
project-specific rules live alongside the import in each repo's CLAUDE.md and
supplement (or override) these.

## Where a remembered rule belongs
When asked to remember something, decide its scope *before* saving it:
- A **cross-project** rule (applies to any of dcltdw's repos) belongs here in
  `AGENTS.md`. When a "remember this" request looks cross-project, say so and
  **ask whether it should go here** rather than into project-local memory.
- A **repo-specific** rule belongs in that repo's `CLAUDE.md`.
- Only **project state or personal context** belongs in private per-project memory.

Defaulting a universal rule into one project's memory is how the same lesson gets
re-learned from scratch in every other repo.

## Model handoffs at phase boundaries
Brainstorming and implementation reward different models, so the boundary
between them is a decision point rather than a seam to slide through.

Roles are the rule; the names below are only today's answer to it:

| phase | model *(mapping current as of 2026-07)* |
|---|---|
| Brainstorming, design, exploring requirements, **writing the plan** | **Fable** |
| **Executing a plan**, implementation, and the verification that follows | **Opus** |

Phases are one axis. Seats *within* a single execution phase — subagent
dispatches in subagent-driven development — are another; see
[Subagent tiers in subagent-driven development](#subagent-tiers-in-subagent-driven-development).

Three events end a turn. When one fires: name the model the next phase wants,
hand over a prompt per [Handing off to another model](#handing-off-to-another-model),
and **stop**. That prompt is the turn's entire deliverable — nothing after it,
no "shall I start?", no offer to carry on.

1. **A plan file exists and execution has not begun.** The moment
   `docs/superpowers/plans/<name>.md` is written, that turn is over.
2. **You are about to propose brainstorming or design on new work.**
3. **Implementation has stopped because the design is wrong.** Not a design
   judgement made in passing — an actual halt.

Nothing else fires this. Fixing review findings, verification, and post-merge
cleanup all belong to the phase already running.

**Anchor these to artifacts, never to how the work feels.** "A plan file was
written" is checkable. "Planning seems finished" is arguable, and anything
arguable gets argued away — which is exactly how the previous version of this
rule failed: a session decided that writing the plan *was* implementation, so
the two were one phase, so no boundary could ever arrive.

**No exemption.** Do this even when you believe the session is already on the
model you would name. You cannot observe which model is running, so that belief
is never load-bearing. Naming the model a phase *wants* is a role question the
table above answers; deciding you are already on it is not, so don't. A
needless handoff costs one sentence — the asymmetry is the whole argument.

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
When the immediate next step you recommend is switching models — "switch to X and
do Y" as the action to take *now*, not a switch mentioned as a later step — hand
over a **ready-to-paste, self-contained prompt** for the new model. Write it to
stand on its own in a fresh session: include the context, goal, constraints, and
any file or ticket paths it needs, rather than assuming it inherits the current
conversation.

## Clarify before proceeding
Before acting on any request — *including* an explicit "please proceed with X" —
if you have a genuine clarifying question about X, or a substantive
countersuggestion or concern, raise it and **wait** for a response before
proceeding. Do not perform agreement, and do not suppress a concern to seem
agreeable.

The flip side: do not manufacture questions when something is genuinely clear.
Proceeding without asking signals you genuinely had none — not that you skipped
the check.

## Before deferring as "blocked"
Before deferring work as blocked — on an upstream dependency, a missing
capability, an unknown — do a cheap, time-boxed **spike** to confirm it is
actually blocked. A deferral resting on a stale assumption wastes the analysis
and just defers again; a few minutes checking the real state (current package
versions, the actual API, a quick probe) often flips "blocked" into "actually a
small change." Record the finding on the ticket either way.

## Concurrent agents
Assume other agents — other sessions, subagents, scheduled jobs — may be
working in this repo and on this machine *right now*. Two hazards, two
different remedies; don't let one rule blur them:

- **The working tree is shared state.** Branch switches, staging, and
  stashes collide silently when two agents share a clone. Do feature work
  in an isolated workspace (`superpowers:using-git-worktrees`) **unless**
  the task must mutate machine-global state anchored to the primary
  clone's path — a checkable exception: name that state before claiming
  it. The Commits rule ("confirm you're on the intended branch") is the
  floor here, not the ceiling.
- **A worktree does not isolate the machine.** Global git config,
  `~/.claude/*`, plugin caches, and install scripts are shared no matter
  where your checkout lives. Before mutating any of it: verify its
  current state first, and restore what you disturb. Never run a script
  that repoints global paths from a throwaway checkout (this repo's
  `install.sh` aims `~/.claude/dcltdw` at its own directory — run from a
  worktree, the pointer would outlive the checkout and strand the
  machine's rule imports).

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

## Branches and PRs
- Never commit directly to `main`. Always work on a branch.
- Open a PR and **wait for approval** before merging — don't merge your own work
  unprompted.
- Prefer **many small, single-purpose PRs** over one large one. Size each ticket
  to one reviewable PR.
- **Opening, presenting, or reporting on a PR → use the `dcltdw:opening-a-pr`
  skill.** (Not installed? `./install.sh` in this repo's clone — see ADOPTING.md.)

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

## Merging a PR, and after
- **Before merging any PR, the moment one merges, or when judging whether a
  branch is leftover or safe to delete → use the
  `dcltdw:cleaning-up-after-pr-merge` skill.** (Not installed?
  `./install.sh` in this repo's clone — see ADOPTING.md.)

## Commits
- Stamp each commit with the current AI model in a `Co-Authored-By:` trailer.
- **Confirm you're on the intended branch before committing** (`git branch
  --show-current` costs nothing). A stray commit on the wrong feature branch —
  another task's, or one you meant to base fresh off `main` — is easy to make
  and fiddly to unpick.

## Before pushing
- A global pre-push hook (installed by `./install.sh`; gitleaks) scans outgoing
  commits for secrets. If the hook warns that gitleaks is missing — or you're on
  a machine without the hook, or the repo has its own `core.hooksPath` (e.g.
  husky) so ours never runs — **scan the diff for secrets manually** (keys,
  tokens, credentials) before every push.

## Before claiming done
- **Verify, don't assert.** Run the actual build/test/command and confirm the
  output before saying something works. Report what was verified vs. assumed; if
  a step was skipped or failed, say so.
- **Re-derive facts from the source, not from earlier prose.** A number carried
  over from a prior summary is not verified — re-check it against the tool
  (`gh run list`, the file, the API). And a check you have not watched *fail* is
  not yet evidence that it can.
- **Verify where the artifact will live, not where you happen to be working.**
  A command that passes in your working tree can prove the wrong thing —
  uncommitted edits, local config, and warm caches all mask failures the next
  person hits. For anything that ships (a branch, a release, a generated file),
  re-run the check in a clean checkout; a throwaway `git worktree` is enough.
- **You cannot observe which model you are running as.** Your system prompt's
  claim about it is not authoritative and a `/model` directive in the transcript
  outranks it, but neither settles the question — so never state the running
  model as fact. Say which one the transcript asked for, and leave it there.
