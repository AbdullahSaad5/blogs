# Blog — Reader Feedback Log

Every published post collects comments and replies. Capture them here, pull the lesson out,
so post N+1 doesn't repeat post N's mistakes. **Read the checklist below before drafting any
new post.**

---

## Rules learned (the running checklist — read before each post)

- **[shipped] Separate "shipped" from "what I'd add" at capture time, and never publish an invented
  control as real.** In a security/systems post especially, claiming a feature you haven't built
  is a live-defense landmine: an interviewer or commenter probes it and the whole "real
  practitioner" brand collapses. When mining, tag each claim as built / planned / aspirational;
  verify the load-bearing ones against the actual repo or docs before they enter the draft. If it's
  not shipped, it goes in an explicit "what I'd add next" framing, never in the present tense.
  _(from Post 05 — Saad had salted in an IP allowlist + agent sandboxing that didn't exist; caught
  in the poke-holes pass and quarantined.)_
- **[stat] Cite a number with its methodology in the same breath.** When you drop a credibility
  stat (e.g. "99% over 1200 commands"), say in the same sentence where the sample came from and
  which way the errors break. A bare number invites the exact question it was meant to answer.
  _(from Post 02)_
- **[voice] Saad writes the spine, or does a real out-loud voice pass, before publishing.** Do
  NOT autopilot-publish an AI draft. The brand moat is "real practitioner"; publishing words
  Saad didn't write erodes it, and he must be able to defend every claim and number live.
  _(from Post 02 process)_
- **[comments] Vet comment authenticity before treating it as validation.** Check account age,
  post velocity, bio, and whether multiple "independent" comments converge on the same angle
  with the same cadence (an LLM tell). dev.to is full of AI / growth-hack commenting. Weak
  signal should not move your self-assessment. _(from Post 02)_
- **[comments] With a suspect account, engage the substance but land the thread cleanly.** A deep
  back-and-forth with a likely-bot can run forever (each round proposes the next architecture).
  Answer well, end on a clean boundary, don't read depth as validation, don't sink unbounded time.
  Mike's comments were wall-to-wall em-dashes (the AI tell) even as the technical points were good.
  _(from Post 02, the 4-round thread)_
- **[mine] Deep comment threads surface real post material.** The good technical exchanges here
  produced a genuine idea ("review the realized diff, not the forecast"). Pull those into the
  backlog instead of burying them in a comment. _(from Post 02)_

---

## Post 02 — plan-mode
Live: https://dev.to/abdullahsaad5/the-hard-part-of-my-ai-agent-wasnt-doing-the-work-it-was-planning-it-n0k

Comments received (2026-06-25):
- **@nazar_boyko** — asked the false-positive vs false-negative split on the 99% classifier:
  which way the ~12 misses broke. A safe call flagged destructive is a free confirm, a
  destructive call waved through is the disaster. Fair and real; the asymmetry is the spec
  hiding behind the headline number. _(account looks genuine: joined 2024, 23 posts, GitHub, site)_
- **@jugeni (Mike Czerwinski)** — three points: (1) how the 1200 commands were *sampled*
  matters more than the rate; suggested adversarial / planted-fault sampling for false-negative
  signal. (2) "review fatigue" = symmetric to SRE alert fatigue; a user reading 40 plans a day
  rubber-stamps and the guarantees collapse silently. (3) praised the data-over-user tiebreaker.
  _(account suspect: 6 days old, 9 posts, persona bio, self-promo; likely AI / growth-hack.)_

Lessons → folded into the checklist above: cite-stat-with-methodology, vet-comment-authenticity.
Saad's real answer to the sampling point (the 1200 = combinations of the registered action set,
i.e. the AI's bounded output space, not user-typed traffic) should have been IN the post.

Thread continued (@jugeni, 2026-06-26 → 06-27) — a 4-round deep exchange. The substance, round by round:
- **Sampling.** Saad: the 1200 weren't production traffic, they're combinations off the registered
  action set, i.e. the AI's bounded output space (the AI can only emit registered actions). So it's
  coverage of the producible space, not observed precision on the user-hit slice. Mike conceded:
  "capability boundary, not query distribution"; residual = the unregistered path a user discovers.
- **Dual gates failing together.** Saad: the two gates read *different inputs* — intent layer reads
  the language/story (where a framing attack lands), classifier reads the raw call form (method/URL/
  body). Confident-benign framing walks past intent, classifier still sees a literal DELETE. For
  predefined actions, destructive is tagged by the action's nature, no description to attack; the
  framing attack only lives on the raw API tail.
- **The residual surface = "destructive in effect, benign in form."** Clean framing + clean form,
  damage server-side. Saad: no gate for it; falls to blast radius + the human (load-bearing, thin).
- **Mike's close:** the only gate that catches that is *post-execution* — read the state delta, ask
  if it was in scope, invalidate/rollback/escalate. Expensive (must define "in scope" to diff).
- **Saad's reply (drafted + voice-passed + clipboard, scratchpad `post02-reply-3.txt`):** agreed
  post-execution is the right shape, added two of his own: (1) the real cost is the **expected-delta
  oracle**, not the diff — predefined actions declare what they write so "in scope" is knowable, the
  raw tail declares nothing, same hole from both sides; (2) short of a full oracle, **put the realized
  diff in front of the human instead of the predicted plan** (run against a snapshot/transaction,
  commit on review) — same load-bearing human, upgraded from reviewing a forecast to ground truth;
  (3) hard boundary = **reversibility** — post-exec rollback only exists where you own the substrate
  (your DB), not on a third party's CRM or a sent email, so the gate closes the surface only where the
  side effect lands on infra you control.

Where it landed (2026-06-27, after a few iterations on the reply):
- Saad **rejected** both proposed automated closes: the "review the realized diff, not the forecast"
  human move (it's the load-bearing-human weak spot relocated, not a real gate) AND the least-privilege
  + auto-invariant structural idea (didn't buy it).
- He **likes** two framings: the **delta comparison** (read the state change, ask if it was in scope)
  and the **reversibility** boundary (rollback only exists where you own the substrate; a third-party
  CRM write or a sent email has no undo).
- Honest position: he does NOT have a clean automated close. The blocker is the **expected delta** —
  the raw tail is undeclared, so there's no spec to diff the realized delta against; and even if you
  could read it, irreversible third-party effects have no undo. Worst case = undeclared AND irreversible
  ("no spec going in, no undo coming out"). The only fallback is the same human again, which isn't a fix.
- **Final reply** (`post02-reply-3.txt`, on clipboard): states all of the above plainly and **bounces
  the open question back to Mike** — "how would you get an expected delta for an undeclared call, or
  close the irreversible case, without putting a human back in the loop?"
- Open problem stands; no post idea committed from this (the human/structural angles were both killed).

## Post 01 — agent-identity
No comment feedback captured yet. Backfill if any arrives.

---

### Template for a new entry
```
## Post NN — slug
Live: <url>
Comments received (date):
- @handle — gist of the point. (real / suspect, and why)
Lesson → what to change next time; promote to the checklist if it generalizes.
```
