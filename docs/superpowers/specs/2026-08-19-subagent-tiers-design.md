# SDD subagent tiers — design

Date: 2026-08-19. Approved in-chat by dcltdw 2026-08-19. Tracked as
dcltdw/agents#10. The evidence base is one measured subagent-driven-
development run (bunnyforge #62 / dcltdw/bunnyforge#67: 10 tasks, 28
dispatches, 2,214,265 subagent tokens).

## Problem

`claude/AGENTS.md` says nothing about which model a **subagent** should run
as. The phase table (§ Model handoffs at phase boundaries) maps *phases of a
session* to models — brainstorming to Fable, execution to Opus.
Subagent-driven development opens a second axis the table doesn't cover:
within a single execution session, which tier does each dispatched **seat**
get — implementer, reviewer, re-reviewer? Today the controller invents that
per session.

What the measured run says the rule should encode:

- **Implementers did not cause rework.** All three fix rounds traced to
  defects in the plan, not implementer error, and the Sonnet implementers
  repeatedly beat the plan — catching a self-defeating `grep -v` filter, an
  unsafe `.gitignore` adoption, and a rename that had made a negative-space
  assertion vacuous. This argues for leaving the implementer tier to
  judgement rather than fixing it high.
- **The tier gap showed in undirected discovery, not directed
  verification.** Sonnet reviewers were strong at checking *named* risks;
  the two findings that came from *nobody asking* — a doctrine
  self-contradiction ~200 lines apart, a walker inconsistency probed on an
  invariant in no brief — were both Opus. This argues for reviewers sitting
  a tier above the implementer as a standing rule.
- **Caveat, carried so the rule isn't overclaimed:** Opus was deliberately
  handed the tasks already flagged hardest, with richer risk lists. The
  comparison is confounded; what survives is the shape of the difference,
  not a clean capability delta.

The hard part is phrasing. "Use the most capable model for reviewers" is
wrong — Fable is the most capable and is overkill for both seats. The rule
is about the Opus and Sonnet layers, so it must express relative position
within a ladder while excluding the top of that ladder, and survive model
releases.

## Decision 1: form — a relational rule, a dated pin, and an explicit ceiling

The issue lays out three candidate forms; each fails alone:

- **Naming models directly** ("Opus reviews, Sonnet implements") is
  unambiguous today and matches the phase table's dated convention, but
  alone it drops the structural claim — *why* the reviewer sits above the
  implementer — so every model release forces re-deriving the rule from
  scratch instead of re-pinning two names.
- **Pure relative position** ("reviewers get a tier above the implementer")
  survives releases but is ambiguous when the implementer is already at the
  top of the intended range, and says nothing about Fable — the misreading
  the rule most needs to prevent.
- **Role vocabulary** ("reviewers get the deep-reasoning tier") needs a
  glossary that itself goes stale, and reads as "the most capable model" —
  the exact misreading again.

Chosen: a fourth form that is the phase table's own pattern, extended. The
phase table already solves the staleness problem with "Roles are the rule;
the names below are only today's answer to it" plus a dated mapping. This
rule does the same: the durable content is stated relationally (reviewers
one tier above the implementer; implementer tier tracks plan specificity),
today's mapping is pinned with a date, and the Fable ceiling is a
first-class clause rather than a caveat — the issue predicted it has to
appear regardless of which form wins.

## Decision 2: the rule text

Normative; the implementation copies it verbatim (mechanical diff-check in
the plan, as on #16), adjusting only if the surrounding file's voice
demands it:

> ## Subagent tiers in subagent-driven development
>
> The phase table above maps *phases of a session* to models. Subagent-driven
> development adds a second axis the table doesn't cover: within one
> execution session, which tier each dispatched **seat** gets — implementer,
> reviewer, re-reviewer. Two rules and a ceiling:
>
> - **Implementers: judgement, no fixed tier.** The right tier tracks how
>   specified the plan is. A plan carrying complete code and exact text is
>   transcription plus testing — the cheaper tier handles it, and in the
>   measured run it beat the plan when the plan was wrong. A plan written in
>   prose needs more capability in the seat.
> - **Reviewers: one tier above the implementer, as a standing rule.** Review
>   is where undirected suspicion pays, and a reviewer working only from the
>   controller's risk list inherits the controller's blind spots. When the
>   implementer already sits at the top of the seat range, the rule
>   saturates: the reviewer sits there too — never above the range — and the
>   lost capability edge is recovered with independence instead: fresh
>   context, and a brief that invites findings beyond the named risks.
> - **The ceiling: no seat runs Fable.** "One tier above" stops at the top of
>   the seat range. Fable is the design-phase model (see the table above); in
>   an execution seat it buys depth neither seat uses, at a multiple of the
>   cost. "Use the most capable model for review" is a misreading of this
>   rule, not a stricter version of it.
>
> The seat range, like the phase table, names models only as today's answer
> *(mapping current as of 2026-08)*: **Sonnet** is the floor and the default
> implementer tier; **Opus** is the top and the reviewer tier. Re-pin on
> model releases.
>
> A dispatch is a request, not an observation — the tier you ask for says
> nothing about which model actually served the seat. Stamp commit trailers
> with what was requested (the Commits rule's model trailer; provenance is
> dcltdw/agents#18).

Choices inside the text, called out:

- The implementer bullet carries one line of evidence ("beat the plan when
  the plan was wrong") because that is the whole argument against fixing the
  tier high; the classification-pin section set the precedent of rules
  carrying their motivating observation.
- Cost appears only as "at a multiple of the cost." Exact figures live in
  this spec (Decision 5) and the issue, not in doctrine, so a price change
  stales the spec rather than the rule.
- The closing paragraph pre-wires consistency with the provenance ticket:
  the rule prescribes *requests*, the trailer records the request, and the
  gap between requested and served is dcltdw/agents#18's problem, not this
  rule's.

## Decision 3: tier collapse — saturate, then compensate with independence

When the implementer is already at the top of the seat range (Opus today),
"one above" has nowhere to go. Chosen: the rule **saturates** — the reviewer
joins the implementer at the range's top and never escalates past it. What
the collapsed gap loses in capability edge is recovered with independence,
which the evidence suggests is much of the mechanism anyway: the undirected
findings came from fresh context and briefs that invited suspicion beyond
the controller's risk list, and both properties are available at any tier.

Rejected alternative: escalating to Fable on collapse. It converts an edge
case into the exact misreading the ceiling exists to prevent, and pays
double Opus rates for design-phase depth an execution seat doesn't use.

## Decision 4: placement — own section, cross-referenced with the phase table

A row in the phase table would be a category error: the table maps phases
of a session, this maps seats within one phase — a second axis. So: **own
section**, placed immediately after "Classification pin: doctrine takes the
architectural path." The pin's ratified placement is *immediately after*
the phase-table section (adjacency is its argument — see the #16 spec);
this section slots in after the pin rather than between them.

Because a reader hitting the phase table will reasonably expect subagent
guidance nearby, the two cross-reference. The new section's opening line
("The phase table above…") points backward; the phase-table section gains
one line pointing forward, inserted directly after the table (normative;
copied verbatim like the rule text):

> Phases are one axis. Seats *within* a single execution phase — subagent
> dispatches in subagent-driven development — are another; see
> [Subagent tiers in subagent-driven development](#subagent-tiers-in-subagent-driven-development).

## Decision 5: cost evidence — re-derived 2026-08-19; the expiry caveat is void

The issue marked its cost figures as needing re-derivation before reliance,
because introductory Sonnet pricing was stated as expiring 2026-08-31.
Re-derived 2026-08-19 from
https://platform.claude.com/docs/en/about-claude/pricing:

- Opus 5: $5 / $25 per MTok in/out. Sonnet 5: $2 / $10. Fable 5: $10 / $50.
- The pricing page now states the Sonnet 5 $2/$10 launch pricing "is now
  the standard price" and that the previously scheduled increase to $3/$15
  on 2026-09-01 "will not occur."

Consequence: the issue's numbers did not move — the caveat attached to them
resolved in their favor. Opus is durably 2.5× Sonnet per token, so the
intro-pricing figures are the standing ones: all-Opus reviewers ≈ **+50%
total session cost** (task-scoped Opus reviews measured ~1.21× the tokens of
Sonnet reviews, on top of the price ratio); all-Opus implementers as well ≈
**2.1×**. The "after expiry" variants quoted in the issue (1.67× ratio,
~+28%, ~1.6×) are obsolete and must not be carried forward. Fable at 2×
Opus and 5× Sonnet per token is the quantitative backing for the ceiling's
"at a multiple of the cost."

None of these numbers enter the normative text (Decision 2). They justify
the rule; the rule does not cite them.

## Out of scope

- **Model provenance.** A dispatch requests a tier; nothing reports which
  model served it, so `Co-Authored-By:` trailers in SDD are asserted rather
  than observed. Filed as dcltdw/agents#18; this spec's rule text is
  written to stay consistent with whatever lands there (it prescribes
  requests and names the ticket) rather than absorbing the problem.
- **Tier guidance for non-SDD subagents** (ad-hoc research or search
  dispatches outside an SDD run) — the evidence covers SDD seats only.
- **The phase table's own mapping** — untouched; this rule only adds the
  second axis beside it.
- **Skill edits.** As with #16, enforcement is by instruction rank; the
  superpowers plugin (including `subagent-driven-development`) is not
  forked or edited.

## Operational impact

The diff is `claude/AGENTS.md` only: one new section plus the one-line
cross-reference after the phase table. No skill changes, so no plugin
version bump and no reinstall on consuming machines. The rule goes live
when the primary clone updates (the `~/.claude/dcltdw` symlink points into
it).

## Verification

- Re-read the rendered AGENTS.md against this spec's two blockquotes after
  landing; the plan carries a mechanical diff-check that the copied text
  matches verbatim, as on #16.
- Anchor check: the cross-reference link resolves against the rendered
  heading (`#subagent-tiers-in-subagent-driven-development`).
- Self-application: this change touches `claude/`, so the classification
  pin forces spec → plan → handoff. This spec is the first artifact of that
  chain; a PR landing the rule without both artifacts refutes itself.
