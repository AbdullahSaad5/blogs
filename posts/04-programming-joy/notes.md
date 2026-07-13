# 04 — "There's no joy in programming now" (pre-AI vs post-AI)

_Raw material from the grill-me interview. The quarry — fill during/after the session, then shape
into draft.md. Opinion essay, not a technical deep-dive. Must end up in Saad's words._

Genre: opinion / personal essay. Lever: traction + personal brand (not the technical pipeline).
Hook/vantage: the person who BUILDS the AI agents saying what they cost — insider, not bitter outsider.

## Spine (target shape)
1. Pre-AI: what the demand was, where the satisfaction lived (cracking the hard thing yourself).
2. Post-AI: the demand flipped — velocity, orchestrate + review AI output, spec instead of solve.
3. What you now *do* to meet the new demand.
4. The honest cost — problem-solving dopamine gone, or relocated?
5. Verdict — clear-eyed trade (lose X, gain Y, your stance), NOT pure elegy. (job-hunt optics)

---

## Interview capture
_(war stories, concrete moments, opinions, lines worth keeping — fill as we go)_

### Pre-AI — the satisfaction

**CENTERPIECE SCENE — the deal-jacket pipeline (junior dev, car-financing).**
- A *deal jacket* = the complete factual deal package sent to a bank for approval: how much down
  payment the user offers, what the car is worth, etc. You send it and ask the bank "approve us or
  not?"
- The pipeline: send the user's info to bank 1, wait ~1 minute for a response, check if a favorable
  deal came back. If not, send to the next bank. A proper pipeline — **a recursive function call with
  managed state in between.** Integrated with **Route One** (US financial company).
- He was a **junior dev** handed this. Wrote it, tested it, checked results, it kept breaking. **3rd
  or 4th day** on it. Hit Postman to fire the request again, watching the logs — it finally ran clean,
  results came back. **Jumped out of his chair**, so loud colleagues turned to look. The one or two who
  knew what he'd been grinding on looked genuinely happy he'd finally cracked it. One of his **first
  big achievements** — still remembers it.

**THE SECOND LOSS (the sharper one) — the thinking-together.**
- Crafting the algorithms *over a whiteboard* with colleagues. Hours thinking through how to implement
  this and that, real discussions, **poking holes in each other's logic.** He misses that feeling.
- "Now you have Claude and you can just ask it to do something and it finds ways to do it for you."
  The loss isn't only the solo solve — it's the collaborative intellectual craft that the agent replaced.
- (Also fixed gnarly things in QR/AES work, but the deal-jacket is THE one that stands out.)

### Post-AI — the demand flip

**CONTRAST SCENE — payment gateways, then vs now.**
- *Pre-AI (junior):* implementing Stripe. Didn't know you don't trust the client-side confirmation —
  you wait for the **backend webhooks** to verify completion: incomplete payment, 3D Secure, card
  declined, fraud. Learned over later projects what the gateway actually demands: **race conditions,
  duplicate webhooks, stale webhooks.** Just the payment gateway itself felt genuinely HARD (separate
  from all the surrounding financial logic).
- *Post-AI (a week/month ago):* another billing system, but different — admin creates **manual
  packages** (not static subscriptions): token-spend limits, connection counts, record counts, session
  counts. **7-8 modules, each with 10+ capture points.** Integrated **QuickBooks + a drive**. AI
  shipped it *with* him in **under a week**, hardened things he'd have missed, "found ways" and guided
  him. He brought his expertise — but watched it have an answer for everything, catch what he missed.

### What we do now to meet it
- The **easy way out**: even a real, brainstormable problem → you just ask AI and it handles it.
- The Slack pattern he's seen: error stack auto-posts to a Slack channel → Claude is in the channel →
  **tag it → it reviews, opens a PR, asks you to review → you review + merge → problem gone.** The
  human never holds the problem.

### The cost
**The human texture that's gone (the part most "AI took my job" takes miss):**
- **Teasing** colleagues — the problem was trivial, you took one look and fixed it.
- The **rubber duck** — explaining a bug to a colleague out loud, it hits you mid-sentence, you stop
  and run back to your laptop to fix it. The machine interaction has none of that — no teasing, no
  shared excitement, no rubber-duck click.
- The **prod-outage adrenaline** — client says there's a problem in prod / a system outage. The
  pressure. Reproducing it, scrolling a huge wall of logs, NOT being able to figure out what's wrong,
  venting to coworkers, teasing them through it. He misses that whole experience.
- "The interaction between the machine and the person is not that." You check its work, find what it
  missed, delete — but the teasing/excitement/rubber-duck part is gone.

### The gain (the other column of the trade — real, un-grudged)
- **10x → 100x/1000x engineer.** The old dream: the 10x engineer who "knows everything about
  everything," the highly-paid one everyone comes to. AI moved the ceiling to 100x/1000x.
- **AI eats the mediocrity, frees you for the craft.** Concrete: building a dashboard. Pre-AI you'd
  burn **2-3 weeks** first on the *structure* — sidebar collapse/expand, tables, filtration, the
  mediocre scaffolding — and only THEN get to the quality-of-life craft (animations, the things that
  put you above a normal front-end dev). Now AI does the mediocrity from the get-go, so **you start on
  your creativity on day one.** Spend your precious time on the craft/edge, not boilerplate.
- **Side projects finally ship.** Old meme: "why spend 1 hour doing it when you can spend 90 hours
  automating it?" The 90-hours barrier is gone — automate in 1 hour with AI. So the tools engineers
  always meant to build get built, and **open-sourced → benefits the community.**
- **Less client↔team misunderstanding.** Old gap: client says X, tech hears Y, PM hears Z. Now the
  client can build a rough prototype with AI and bring it to you ("I want something like this") — much
  clearer signal of what they actually want.
- **Thesis of the gain:** AI took over the normal/mediocre work and freed us to focus on the
  creativity, the edge, the craft that takes an app to the next level.

### Verdict / where you actually land
- **Stance = (c) TRADED**, not gone (a) or cleanly relocated (b). Lost something real, gained something
  real, ambivalent and counting the cost. The loss must be written with real teeth — no fake-balanced
  "but it's all fine." The ache is what keeps it from being corporate filler.

**THE REAL THESIS (crystallized) — the joy was OWNERSHIP + EARNED APPRECIATION, and AI severed both.**
- The joy = the joy of **problem-solving** AND of **owning what you made**. Pre-AI, even a simple HTML
  page was entirely yours: you learned to code, you built it, you could *claim* it. Ownership.
- AI commoditized building. People who don't know how to code now step in and ship. So **building stops
  meaning anything** — if you built the next Facebook, people would say "you did it with AI." AI takes
  the credit for everything. Double cut: those who didn't do it take credit; and real work is dismissed
  with "I could do that too."
- **Craft flattened to "who has the best AI."** Front-end, look-and-feel: the client only sees the
  result, never what's underneath. A junior with Claude Opus out-builds a senior on a weaker model —
  not on code, on look and feel. The craft you poured heart and soul into for years, gone — "a script
  can do that with a powerful tool, and it has flooded the market. There is no real appreciation for a
  good application out there."
- **His own closing synthesis (use near the end):** "AI has helped us a lot — productivity, how we
  code, how we think about problems, how we manage products, how many we manage, ship quicker, feedback
  quicker, improve quicker. But the main thing, the joy, that is what has been crushed in between all
  of that."

### The ending (LOCKED)
- **Aim WIDE, not personal.** The point is the death of *appreciation for craft in general* — "we
  stopped being able to tell good from generated, so nobody values either." NOT "credit me." This
  de-risks the status-anxiety read and is truer to what he means.
- **Soften the close — NOT "crushed."** The joy is diminished/changed, not dead. Land on something
  survivable, not elegy (keeps it (c) trade, protects job-hunt optics). Candidate last beat: the public
  scoreboard for craft is broken, but the **private** satisfaction of doing the hard part yourself is
  still yours **if you choose it** — the joy stopped being handed to you and became something you opt
  into on purpose.
- **Wants MORE "goodness of AI"** folded in to balance/soften (see suggestions below — keep only the
  ones Saad can personally stand behind).

### Goodness-of-AI to fold in (ALL FOUR confirmed true by Saad)
1. **Democratization = same coin as the craft-loss.** The sting (anyone can build, so building means
   less) IS the best thing AI did: people with real ideas and no CS degree finally make them. Loss and
   gain are one fact seen from two sides — the thematic key that makes the softened ending land.
2. **AI as a tutor — levels juniors fast.** The webhook/race-condition/3D-Secure knowledge that took
   Saad multiple projects to learn, a junior gets day one because AI explains while it builds. Callback
   to the Stripe beat-1 story.
3. **Killed the toil, not just the craft.** Boilerplate, config, migrations, glue code, the 2am
   won't-build pain — gone. Less burnout on the stuff nobody loved. (Honest: not all AI took was joy.)
4. **Lowered the cost of curiosity.** Try three approaches in the time one used to take; poke a new
   language/domain without weeks of ramp. The "what if" is cheap, so you actually explore.

(Plus already-captured gains: 100x engineer, AI eats boilerplate→creativity day one, side projects
finally ship + open-source, smaller client↔team understanding gap.)
