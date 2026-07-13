# Post 02 — Plan Mode (raw material)

_Sequel to post 01 (agent-identity). Teased at the end of 01: "the planning turned out to
be harder and more interesting than the doing." This post must pay that off._

Angle: how the agent plans all steps before touching anything, how it decides what counts
as a destructive step worth stopping for, what we built one way and had to tear out and redo,
and what we learned.

## Captured (interview 2026-06-25)

### The redo story (the spine — "planning harder than the doing")
THREE rebuilds, each a before -> wall -> after:

**Redo 1 — plan mode lived inside the main agent.** First version: a trigger keyword in a
message flips the main agent into planner behavior. Same agent did BOTH direct mode (just do
the stuff) and plan mode (plan, then do). Wall: the two interfered with each other, the main
agent couldn't be both. After: tore plan mode OUT into a SEPARATE agent with its own
rewritten system prompt — that agent only researches and produces a plan, never executes.

**Redo 2 — the planner made arbitrary plans.** It planned blind: assumed what existed inside
an app (e.g. what a Salesforce org already had) instead of looking. Plans were built on
assumptions, which broke on contact. After: gave the planner read-only / non-destructive
research tools so it inspects the actual state first, THEN plans.

**Redo 3 — the planner was too aggressive.** Even with tools it wanted to emit a plan
immediately, skip research, not ask questions. After: forced it to ask the right questions
first. But not redundant basic ones (bad UX). Trick: it still asks, but each question comes
PRE-FILLED with a recommended answer Saad already supplies, so the user confirms instead of
typing everything. Then it researches and produces a solid plan.

### The two-agent context handoff (novel bit)
Planner and main agent = different agents, different sessions, different memories. All the
planning conversation (the why, the findings, the assumptions, the risks) happened with the
PLANNER. To execute, the plan is handed to the MAIN agent — which was never in that
conversation and so lacked all context. Fix: made the planner emit a CONCISE output that
packs the assumptions + risks + steps into the handoff, so the main agent inherits ~90% of
the planning context and knows what it's doing and why.

### Destructive-step detection
The planner auto-marks steps as destructive by their NATURE — addition, deletion, renaming,
etc. At execution, when the main agent hits a step marked destructive, it explicitly asks the
user to confirm before running it. Human-in-the-loop. User approves -> it runs.

### Step criticality: must / should / could
Each step gets a criticality that decides whether a failure fails the whole plan:
- **must** — integral, the core of the plan; this had to happen. (must-fail = plan failed)
- **should** — on failure, the choice goes to the USER: skip to next step, or retry?
- **could** — planner decides it's optional (e.g. a backfill/migration of backward records).
  Happens = good. Doesn't = just notify the user and continue.

### Evidence + divergence + abort/replan (the plan is NOT static)
The planner doesn't just research — it VERIFIES and attaches EVIDENCE to each step it
plans. So at execution, the main agent can check the step against that evidence. If reality
no longer matches (plan outdated, research outdated), it can PAUSE the plan, mark the step
FAILED, and explicitly tell the user "the thing you claimed in the plan is not like this."

Three escape hatches when a plan goes stale:
1. The user can CANCEL / abort the currently-running plan at any time.
2. After aborting (or anytime in the same chat) you go back to the planner and REPLAN. The
   planner agent keeps its context across the session — memory, last messages, what happened
   before — so it can redraw the plan from the NEW evidence/data. No limit on how many times
   you bounce back to it in one session. (Refines the "different memories" note above: the
   planner retains ITS OWN context across replans; the cross-agent gap was planner->main, and
   the concise-handoff fixes that.)
3. The MAIN agent itself has agency at a divergence: it can either proceed with the outdated
   plan (adapt, do the new things inline) OR flag "this plan is outdated, can you give me a
   new plan?" and kick it back to the planner.

So divergence is handled three ways at once: must/should/could on step failure, evidence
checks that can pause and surface a stale claim, and a human/agent-triggered replan loop.

### What the user sees in the plan (closes the post-01 wrong-alias gap)
The plan is a list of actionable steps in plain English, sometimes technical where it helps —
e.g. for a Salesforce user it names the actual custom objects and custom fields it will touch.
Each step surfaces:
- the action in plain language,
- the concrete things it will interact with (object/field names),
- IMPACT — e.g. how many people/records it will affect,
- the ALIAS it will act on (never the raw id — same alias system as post 01), so you can SEE
  which connection each step targets before anything runs.
And when you have multiple connections that fit, plan mode pops a SELECTABLE correction — pick
which connection to use — so the wrong-org pick from post 01 surfaces as an explicit choice in
front of you, not a silent guess. Each step also clarifies what's there, what isn't, and where
it will operate. THIS is the concrete payoff post 01 promised.

### The trigger — it's a UI toggle, always the user's call
Default is direct mode; the composer shows which mode you're in. There's a control on the
composer you click to flip to plan mode (and back). The agent never sniffs stakes and silently
escalates you — it's an explicit human choice. "Plan mode" is deliberately the same term other
AI tools use, so a normal user already gets the contract: make a plan, review it, edit it or
approve it, then hand it off to the main agent to execute.

### Destructive detection — two layers (handles the raw-API hole)
1. **Intent reasoning.** For a raw API call there's no predefined action to tag, so the agent
   judges by INTENT — what the call is actually going to do. It's an LLM, it knows. A call can
   be flagged destructive even if it's a GET, when the intent is destructive. Verb alone
   doesn't decide it (my POST/GET guess was too crude).
2. **A command classifier.** A separate classifier looks at the WHOLE command — action name +
   other factors — and decides safe vs destructive, and can intercept. Tested on 1200
   different commands, ~99% accuracy. This is the deterministic backstop under the LLM's
   judgment. (Nice concrete number for the post.)

### The pause is one mechanism, and it prefers DATA over the user
The destructive-confirm and the divergence-pause are the SAME stop. At a confirmation (e.g.
"proceed to the next step?") it also shows you the EVIDENCE from the previous step so you can
verify what happened. If you claim a step wasn't done and ask to retry, it does NOT redo
blindly — it checks the evidence and can QUERY the platform to see the real current state, and
it prefers the data over your assertion. It'll push back: "no, I already did this, you're
wrong." (Good moment for the post: the agent trusts verified evidence over the human's claim.)

### The plan is a dependency graph, and the pause freezes the whole thing
The plan isn't a flat list — it emits DEPENDENCIES (this step depends on these steps). Steps
whose dependencies are satisfied / that are independent can run in PARALLEL; dependent steps
wait. So it's a DAG, not a line. When a destructive step pauses, it pauses the WHOLE plan, not
just that branch.
  [VERIFY w/ Saad: his spoken example ("3,4,5 depend on 6, so 3,4,5 run in parallel, then 6")
  had the dependency direction ambiguous — confirm which way the arrows point before drafting
  the diagram. Intent is clear: independent steps parallelize, dependents wait.]

### Where it still falls short (the honest section)
- **Prompt injection is still real** — plan mode doesn't kill it. Two things bound it: (1) the
  agent has no arbitrary/"proper" execution — it can only act through the defined actions and
  the connections you authorized, so an injected instruction can't make it do anything outside
  that surface; and (2) in plan mode the client/user reviews the plan first. So injection is
  BOUNDED (limited capability + human review), not solved.
- **The planner can still pick the wrong application/connection.** A confidently-wrong planner
  draws a clean-looking plan. The defense is exactly the review step — the user sees which
  connection/alias each step targets and what it's getting into, and catches it BEFORE it runs.

THE HONEST ADMISSION (parallels post 01's "untrusted content in direct mode" line): both
remaining gaps — injection and the wrong-pick — fall back on the HUMAN actually reading the
plan. Plan mode moves the safety from "trust the model" to "trust the human to review," which
is better, but it's only as strong as a user who doesn't rubber-stamp. The structural wins
(bounded capability surface, the alias/identity work from post 01, the command classifier) do
the rest; review carries the part structure can't.

## Open verify before drafting
- DAG arrow direction (step dependency example) — not yet confirmed by Saad.

## STATUS: batch 1 + 2 mined. Enough material to draft. Next: outline -> draft (voice-profile).

## Carryover threads from post 01
- Plan mode is the answer to the two gaps post 01 left open: wrong-alias pick inside a
  session, and prompt injection (injected destructive actions still hit the confirmation).
  This post should close those loops concretely.

## Carryover threads from post 01
- Plan mode is the answer to the two gaps post 01 left open: wrong-alias pick inside a
  session, and prompt injection (injected destructive actions still hit the confirmation).
  This post should close those loops concretely.
