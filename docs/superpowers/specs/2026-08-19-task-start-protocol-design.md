# Task-start protocol — design

Date: 2026-08-19. Approved in-chat (brainstorming session, contested points
ratified by dcltdw). Tracked as dcltdw/agents#13; the fleet-wide sync it
implies is dcltdw/agents#14.

## Problem

An agent starting a task has no obligation to anchor the work to an issue or
a board card, so work regularly lands as a PR with no trackable ticket behind
it. AGENTS.md's Project board section says to *track* work on the board but
never says when a card comes into existence, who creates the issue, or what a
board must look like. The evidence that the current rule does not
self-enforce is already on the boards: four of the eight boards lack the
"Won't Do" status that the existing rule explicitly requires agents to add.

## Survey (2026-08-19, all dcltdw boards and repos)

Status fields across the eight GitHub Projects:

| Boards | Status options |
|---|---|
| Agent tooling (8), bunnyforge split (7), annotated-maps-sp (6) | Todo / In Progress / Done / Won't Do |
| Flightdeck (5), swarsy-face (4), Understated (3), Focus on next (1) | Todo / In Progress / Done — missing Won't Do |
| gtfs-demo (2) | Todo / In Progress / In Review / Done / Won't Do |

Labels: every repo carries GitHub's nine defaults; extras vary per repo
(bunnyforge: `deferred`, `mcp`; annotated-maps: `maintenance`,
`priority: *`; gtfs-demo: `type:*`, `priority:*`; annotated-maps-sp:
`docs-accuracy`, `semver-major`; agents/scripts/bunnyforge-visibility-preview:
`accessibility`). Priority is encoded three different ways across the fleet.

Linking: only four of eight projects are formally linked to a repository.
bunnyforge split, Flightdeck, swarsy-face, and Understated have no linked
repo — board discovery from the repo side fails there today. Full drift
detail and the work items to fix it live in #14; this design only depends on
the facts above.

## Decision 1: a "Starting a task" section in AGENTS.md

New section in `claude/AGENTS.md`, placed immediately before "Branches and
PRs". The rule, anchored to a checkable artifact in the file's established
style:

**Before creating the work branch, the task must have an issue, and the
issue must be on the repo's board.** In order:

1. **No issue covering this task? Create one** — sized to one reviewable PR
   (the existing sizing rule in Branches and PRs).
2. **Find the board via the repo's linked projects** (`gh repo view --json
   projectsV2` or GraphQL `repository.projectsV2`). No linked board, or more
   than one plausible candidate? **Stop and ask** — the answer may be
   "create one" or "this existing board is correct." Never create a board
   unprompted.
3. **Creating a board (only after approval):** use the canonical schema in
   the Project board section, and link the new project to the repo so the
   next agent can discover it mechanically.
4. **The PR references the issue** — `Closes #N`, or `Refs #N` when the PR
   does not finish the issue. Enforcement lives in the `dcltdw:opening-a-pr`
   skill (Decision 3).

Branch creation is the anchor deliberately: it is checkable (the same
discipline as the model-handoff rule's artifact anchors), and it naturally
exempts sessions that never produce a branch — a question answered, a spike
reported. "Starting work" would be arguable, and anything arguable gets
argued away.

## Decision 2: canonical board schema, enumerated in AGENTS.md

The Project board section gains the schema; it is the target both for any
newly created board and for the #14 sync:

- **Status**: `Todo` / `In Progress` / `Done` / `Won't Do` — nothing else.
  gtfs-demo's extra `In Review` is dropped (ratified 2026-08-19): review
  state is visible on the PR itself, a board column duplicating it is one
  more manual move per task, and seven of eight boards already live without
  it.
- **Labels**: GitHub's nine defaults plus `deferred` — "Real work,
  deliberately parked — revisit when the need is live (not wontfix)"
  (bunnyforge's wording, universalized because it fills a real gap next to
  `wontfix`).
- **Priority is repo-local** (ratified 2026-08-19): only three of twelve
  repos use any priority scheme, and the need it serves is largely captured
  by `deferred`. Repos that want one keep it; the canonical set stays out of
  it. Repo-specific domain labels (`mcp`, `docs-accuracy`, `semver-major`,
  …) are likewise fine and stay repo-local.

The existing bullets in the section (terminal states Done / Won't Do with a
one-line reason; refinement/triage vocabulary) stay as they are — the schema
bullet absorbs the "add a Won't Do status if the board lacks one"
instruction, since Won't Do is now part of the enumerated schema.

## Decision 3: `dcltdw:opening-a-pr` owns the `Closes #N` check

AGENTS.md states the rule; the skill enforces it — the same division that
closed #11 for changelogs (a requirement that lives only in prose "depends
on being remembered"; a requirement in the skill that gates every PR gets
checked every time). Two edits to the skill:

- "Before opening" gains a step: confirm the task's issue exists and its
  card is the one being moved Todo → In Progress (the move is already step
  2; it gains the issue as its object).
- The PR body requirements gain: **the body's first line is `Closes #N`**
  (`Refs #N` when the PR does not finish the issue) — above the five
  required sections. First-line placement is checkable at a glance and keeps
  GitHub's auto-close linking working.

## Out of scope

- **Board/label sync across the fleet** — #14, blocked on this design
  merging. Includes adding Won't Do to four boards, dropping In Review,
  normalizing or retiring per-repo priority labels, adding `deferred`
  everywhere, and linking the four unlinked projects.
- **New tooling.** No scripts, no automation; the protocol is prose plus an
  existing `gh` query.

## Operational impact

- The `opening-a-pr` skill change means a plugin version bump
  (0.3.0 → 0.4.0 in `claude/.claude-plugin/plugin.json`) and a plugin
  update/reinstall on machines that consume it.
- The AGENTS.md change goes live when the primary clone updates (the
  `~/.claude/dcltdw` symlink points into it) — no reinstall needed.

## Error handling

The only failure branch with judgment in it is board discovery. The rule
resolves every ambiguous outcome the same way: **stop and ask**. No linked
board, multiple linked boards, a board that looks wrong for the repo — all
stop-and-ask. The agent never creates a board, links a project, or guesses a
board on its own authority.

## Verification

- Re-read the rendered AGENTS.md section against this spec's rule text.
- Dry-run the discovery query against a linked repo (expect: board found)
  and an unlinked one, e.g. scripts (expect: empty → the stop-and-ask
  branch).
- Confirm the plugin version bump is present and `install.sh --check` still
  passes on the primary clone after merge (not from the worktree — its
  install.sh must never run from a throwaway checkout).
