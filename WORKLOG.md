# Blog — Worklog

Dated log of what we did each session, newest first, so the work is recallable next time.
Append a dated block whenever we do blog work.

---

## 2026-08-03 (session 9 — post 07 edit pass, factual pass, title lock, devto.md staged)

- **Edit pass on post 07** (`posts/07-senior-thinking/`): mechanical checks clean (0 em-dashes, no AI-tell phrases, no antithesis-reversal, all paragraphs ≤240 chars, 1,365 words). Tightened one redundancy (browser on-demand sentence duplicated). Added a VERIFY block to the draft header flagging 5 load-bearing claims for Saad.
- **Title locked: "How to Think Like a Senior Developer"** (Saad chose option 2 of 5; safe/searchable register, no antithesis-reversal shapes). Recorded in draft header.
- **Factual pass COMPLETE (all 5 confirmed by Saad):**
  1. Browser memory 300–400 MB per user + thousands of users → hundreds of GB: confirmed as written.
  2. Browser optimizations: **built and tested locally, not shipped** — draft now says exactly that ("We built and tested those optimizations locally."), per the [shipped] feedback-log rule.
  3. Stripe fix order: payment intent comes first, its ID saved to the DB, THEN charge; webhook matches later. Draft rewritten ("I reordered the workflow so the payment intent came first...").
  4. Stripe retries: handler returns 200 (no Stripe retry), webhook saved to DB as pending, cron matches 3–4 more times, stays pending for admin review, logged. Draft rewritten (split into two paragraphs to stay ≤240 chars).
  5. Two per-user services: confirmed.
- **devto.md built + verified**: frontmatter (title, published:false, tags `programming, career, softwareengineering, productivity`, cover blank), body byte-identical to draft minus the H1/comment, 0 em-dashes, no AI tells, 1,467 words total.
- **Still required before live:** Saad's out-loud voice pass on the final text (read it aloud), cover (1600x840 ink+gold brand template, drag-drop in editor — API can't upload), then flip published:true (PUT to the dev.to article id once staged), then Medium import + Hashnode paste with canonical → dev.to, then profile README + portfolio card.

---

## 2026-07-28 (session 8 — post 07 senior-thinking interview + first draft)

- **Post 07 interview resumed** in `posts/07-senior-thinking/notes.md`. Saad supplied the core view:
  senior thinking means testing whether a report is a symptom, tracing a change through its callers
  and workflows, documenting decisions and assumptions, asking the client obvious questions, and
  putting risk into the estimate instead of promising the best case.
- **Four real stories captured:** (1) an e-commerce catalog/stock/listing model rebuilt after the
  team assumed all three shared one lifecycle; (2) seven marketplace categories became 43, so the
  team replaced hard-coded field unions with runtime schema-driven forms; (3) per-user agent browser
  control worked but carried roughly 300–400 MB per user, leading to a lighter UI plus on-demand and
  idle teardown; (4) a missing background check traced to Stripe delivering a webhook before
  MongoDB stored the payment intent ID, fixed by persisting first and making missing-record delivery
  retryable.
- **Workflow correction:** drafting initially started too early. Re-read the complete blog process
  (`CLAUDE.md`, README, PLAN, WORKLOG, feedback checklist, voice profile, ideas, publishing notes)
  plus the interview/shaping/editing skills. Returned to raw capture, then shaped only after Saad
  chose the e-commerce assumption as the opening.
- **First complete `draft.md` written** (~1,365 words). Path: wrong assumption → ask/document →
  7-to-43 extensibility → per-user scaling → Stripe workflow tracing → risk-aware estimation.
  Mechanical pass currently clean: every paragraph ≤240 characters, 0 em-dashes, and none of the
  stored banned AI-tell phrases.
- **Still required:** Saad factual + out-loud voice pass, especially the browser service memory
  figure and Stripe retry wording; tighten any sections that sound too polished; lock the title.
  No `devto.md`, cover, staging, or publishing work has been done.

---

## 2026-07-13 (session 7 — post 06 two-tokens OAuth explainer drafted + pushed as dev.to draft)

- **Post 06 created** (`posts/06-two-tokens-oauth/`). The "Why two tokens? OAuth access vs refresh,
  explained by someone who was confused by it" explainer from PLAN.md. Tight sibling to post 05.
- **Mined Saad's real confusion 1-by-1** into `notes.md` (5 questions). The genuine arc:
  making a login API, colleague says newer APIs return two tokens, **neither dev knew why**; Saad
  called two tokens overhead and shipped **a single JWT with a ~7-year life and no revocation** (never
  bit him only because the project never shipped — "I got lucky, not smart").
- **PLAN premise corrected mid-interview:** the eureka did NOT come from building the agent
  key-exchange (post 05). It clicked earlier, from a **YouTube explainer** that dropped the two
  missing concepts — **revocation/blacklisting** (killed his "tokens are stateless so revocation is
  pointless" assumption) and **scopes**. He then built a login/signup/refresh demo in **under an
  hour**. Post 05 is reframed as the **payoff** (agent can't re-auth like a human), not the click.
- **Skeptical close kept (voice gold):** for most apps one token + sessions + a sane 7d/30d life is
  fine; two-token machinery (refresh timer, blacklist, refresh-race) is more moving parts. The
  7-year JWT was dumb for being **unbounded**, not for being one token.
- **draft.md written** by Claude from the 7-point spine (~1560 words). Voice self-check passed:
  **0 em-dashes**, none of the flagged AI tells. Saad has NOT yet done the out-loud voice pass —
  flagged the one borderline windup ("Here's the version I wish someone had handed me").
- **Pushed to dev.to as DRAFT** (`published: false`). **Article id `4133781`.** Tags:
  oauth, security, webdev, authentication. No cover yet (API can't upload images).
- **Still TODO before publish:** Saad voice-pass; add cover in web editor; resolve the windup line;
  swap in the real post-05 link once 05 is live; then flip `published: true` (PUT to id 4133781).
- **Same session — mid-draft corrections + poke-holes hardening (all Saad-confirmed):**
  - Colleague was a **front-end dev** who'd only *seen* two tokens on a backend project; asked the
    builder why and got **"it's industry standard"** = the whole answer. The "why" was lost one hop
    up the chain. (Opening rewritten.)
  - Added the **months-long gap:** after the convo they kept shipping single-token for months (a
    handful of juniors, nobody senior to ask, "JWT is the way") until the YouTube click. Makes the
    "too easy" self-laugh land harder.
  - **OAuth2 ≠ two-token pattern de-conflated** (Saad flagged): his login API was the two-token
    pattern, NOT OAuth2. OAuth2 = the delegation framework (login-with-Google/connect-bank); the
    access/refresh pair is one mechanism you can use in your own auth. Added a clarifier para + fixed
    the "same OAuth2 I researched" line to "lumped it in with OAuth2." Description updated.
  - **Poke-holes pass fixed 5 real holes** (see notes.md "Technical model" block for the confirmed
    facts): (1) statelessness contradiction — access = stateless JWT no lookup, refresh = the only
    thing checked (DB row), "best of both worlds" between session + pure JWT; (2) refresh is NOT a
    JWT, it's an opaque deletable DB row; (3) closed past-Saad's "still stealable" objection via
    killable + one-route-only; (4) refresh lives in a **signed httpOnly cookie**, and (5) **never
    localStorage** (npm dep / injected script reads it silently, no log trail); plus reconciled the
    agent system (post 05) as the deliberate exception that checks access live every call (buys
    instant revocation with a per-call lookup). Post grew ~1560 → ~2250 words. Still 0 em-dashes.
  - **Title set:** "Access vs Refresh Tokens: I Was Missing Two Ideas" (checked dev.to convention:
    topic is saturated with plain "Access and Refresh Tokens Explained" titles → kept the search
    keyword up front for SEO parity + confessional tail for the click). Live on draft 4133781.
  - **Covers generated** (HTML→PNG, headless Chrome, saved generator HTML next to each PNG):
    `cover.png` + `cover-devto.html` (2000x840, dev.to), `cover-1600.png` + `cover-1600.html`
    (1600x840, Hashnode). **v1 used floating keys → too close to post 05's cover; Saad flagged.
    REDESIGNED v2:** two credential CARDS instead of keys — cyan ACCESS card (segmented JWT chip,
    "expires ~15 min", "stateless, sent on every request") + gold REFRESH card (lock + opaque DB-row
    bar, "long-lived", "opaque row in the DB, so you can delete it"), with a dotted "MINTS NEW" arrow
    from refresh up to access. Dropped the bad refresh key/arrow glyph and the "building agents that
    ship" byline tagline (now just "Syed Abdullah Saad"). Kept brand base (dark ink, Fraunces +
    JetBrains Mono, dot grid). **Still need to drag-drop into the dev.to/Hashnode editors** (API
    can't upload images) to get the S3 URL for `cover_image`.
  - **Scope tightened to tokens-only (Saad):** removed the OAuth2-vs-two-token clarifier paragraph +
    the "lumped it in with OAuth2" click-line mention (he found the OAuth2 framing redundant), AND
    removed the entire "Where it finally mattered for me" agent/AI section + the "autonomous agent"
    example in the close (wants this piece purely about tokens, no AI tie-in). Post is now a clean
    standalone JWT access/refresh explainer, ~1830 words, 0 em-dashes. Dropping the agent section
    also removed the post-05 link dependency (that TODO is moot). `oauth` tag still on the post
    (open question: keep for search traffic vs swap to `jwt`).

---

## 2026-06-29 (session 6 — post 05 agent-key-exchange mined, 3 new ideas logged)

- **Post 05 created + mined** (`posts/05-agent-key-exchange/notes.md`, ~16 fragments). Ran
  `writing-fragments` to grill Saad on the agent key-exchange system. Spine = **"never mint a key
  with a key"**: an autonomous container must refresh its own creds with no human, but a leaked key
  must not be able to mint new authority. Grounded in the real work docs
  (`black-box/docs/AGENT_KEY_{EXCHANGE,PROTOCOL,API_KEYS}.md`) — read but NOT named (IP rule).
- **Shipped design captured:** short-lived **access** key (1hr, configurable) + long **refresh**
  token (only scope = `refresh`); proactive refresh at **75%** of lifetime so nothing expires
  mid-task; scopes fixed at mint from admin grants (CRM / Automations / Projects + read/write),
  ceiling = owner's own perms; every token matched against a **per-user hash** at verify.
- **Big correction mid-session (Saad caught it):** initial draft claimed access tokens are
  "stateless, wait it out." WRONG — verify does a per-user hash lookup, so access IS instantly
  revocable (rewrite the user's hash → all their tokens die next call). Reframed the whole spine:
  access/refresh split is **job + lifetime**, not storage. Added the teaching centerpiece — **you
  can't have stateless + instantly-revocable for free**; 4 industry patterns (short-TTL-only /
  token-version / denylist / opaque); Saad built **token-versioning** (the per-user hash); the
  per-request lookup he noticed IS the bill for instant revocation. Short TTL's real job = bound the
  leaks you NEVER detect; the hash handles the ones you do.
- **AI-security posture (the scarce, on-brand half):** credential never enters the model's context
  (engine/script does all token plumbing) → prompt injection has nothing to steal; input guardrails
  (prompt + script injection); post-model **output reviewer** to catch exfiltration; whitelisted
  egress; **anomaly tripwire** (off-pattern usage / unlisted IP → block the refresh key on the spot).
  Thesis close: *you don't trust the model; you build so it being wrong costs as little as possible.*
- **Kills (all instant, differ by blast radius):** per-user (rewrite hash) vs tenant nuke (clear
  gateway token → container fatal). Permission promote/demote rewrites the container key files live
  so the agent never runs on stale perms. Grace window on old refresh; concurrent-refresh race left
  to self-heal via 401-retry (no lock — "cheapest correct answer").
- **Rate-limit numbers: derived, not invented** (honoring the post-02 cite-with-methodology rule).
  1hr TTL + 75% refresh → ~30/day healthy → cap order-of-magnitude above (~10/hr, ~200/day per
  tenant). Framed as conventional defaults, not exact prod caps.
- **Likely TWO posts:** (A) credential design, (B) "you don't trust the model" AI-security posture.
- **3 new ideas logged in PLAN.md** (standalone/opinion + explainer levers): (1) **"How to think
  like a senior engineer"** — seeing beyond the diff (seeded by the key-exchange "leaked key
  re-mints forever" catch); (2) **"Why two tokens? OAuth access vs refresh"** explainer, tight
  sibling to post 05; (3) marked post 04 PUBLISHED in PLAN.
- **Poke-holes pass done + most fixed from the real docs.** Grace=60s (response-loss replay, not
  in-flight); refresh is ROLLING with reuse-detection (answers the end-of-life / key-mints-key
  worry); one container per user + single-flight refresh (kills the multi-replica livelock); hash
  mechanism = doc's `sha256(secret+GLOBAL pepper)` per-key + LIVE re-check every request + revokedAt
  cascade (NOT a per-user hash rewrite — Saad's "rewrite the user's hash" was a misremember; doc is
  authoritative). Reconciliation centerpiece reframed to introspection/live-re-check model; the
  stateless-vs-revocable insight survives.
- **CRITICAL integrity catch:** Saad confirmed the **IP/anomaly allowlist and agent sandboxing were
  INVENTED** (not shipped) — CUT from the draft. This is the brand risk the whole "real
  practitioner" posture exists to prevent. Three more Post-B claims (input prompt/script-injection
  guardrails, post-model output reviewer, whitelisted egress) were described verbally but NOT
  doc-verified; given two features were already aspirational, they're now in a **QUARANTINE block**
  in notes.md (commented out, won't publish) pending Saad confirming each is actually built. The
  closing thesis line is held pending which rings are real.
  **RESOLVED same session:** Saad confirmed input prompt/script-injection guardrails + post-model
  output reviewer ARE built → restored as shipped (present tense). Whitelisted egress NOT confirmed
  → dropped from the draft. Closing thesis rewritten to stand only on verified layers: credential
  out of context, input screening, output screening, bounded by the short-lived revocable key.
  Quarantine block removed. Post B is intact and fully ground-truthed.
- **Lesson for the checklist:** when mining a security/systems post, separate "shipped" from "what
  I'd add" at capture time. An invented control in a job-hunt post is a live-defense landmine.
  Post-B ("you don't trust the model") is thinner than first mined until the 3 claims are verified;
  the credential-isolation beat is doc-real and stands.

## 2026-06-29 (session 6b — post 05 drafted, titled, covered, pushed to dev.to as draft)

- **Reframed the whole post to the SINGLE-KEY spine** (Saad supplied the real why mid-session): three
  services (CRM / automations / projects), three key shapes, some admin-only. Prototype wired raw
  keys in → watched the agent go past its instructions and pull restricted data → "the prompt is not
  an access boundary." Fix = ONE key the agent holds, aliased to all three platforms; backend
  resolves the real credential, and for admin keys mints a short user-scoped token instead of ever
  exposing the admin key. 3 keys → 1, plus an expansion seam. Access/refresh demoted to "the key
  renews itself in the background" (no dual-key framing, per Saad). New why-fragments saved in notes.
- **draft.md rewritten** (~2200 words, 0 em-dashes, IP-clean). Prompt-leak discovery is the through-
  line, paid off in the "you don't trust the model" close.
- **Title locked** (Saad picked, after rejecting two batches — the post-04 personal/paradox register
  beats the post-02 technical-turn register): *"My agent kept reading data it wasn't allowed to. The
  prompt was never going to stop it."* Cover line is separate: "The agent gets one key, and never the
  real one."
- **Covers built** (bespoke, own personality vs 04's gold): cold cyan-steel, one glowing key in
  front of three dimmed ghost keys (= the thesis). `cover-1600.png` (Hashnode 1600x840) +
  `cover.png` (dev.to 2000x840); both HTML generators saved next to the PNGs per the standing rule.
- **Pushed to dev.to as DRAFT** (`published:false`, id **4024982**). devto.md created. Cover NOT
  uploaded (API can't); add via web editor drag-drop before publish.
- **Cover uploaded + wired** (Saad drag-dropped in editor; S3 url in devto.md cover_image; PUT to
  4024982). Memory note: dev.to API can't upload, so this step is always manual web-editor + PUT.
- **FULL REWRITE to coherent single-key** (Saad: "the article doesn't make sense, narrowed to one
  key but still talks about refresh grants"). He was right. Cut ALL two-key machinery: access/refresh
  pair, "never mint a key with a key," rolling rotation + reuse detection, 60s grace, single-flight,
  the separate refresh credential. The single-key model dissolves it: because the key is checked live
  every call + instantly revocable, self-renewal is safe (renewal re-validates against live state, so
  it can't outrun revocation). Added honest bearer-key caveat (silent theft = user-level access til
  noticed; design keeps it small: alias-only, perm-capped, short window, dead-on-next-call). Kept:
  prompt-leak why, aliasing + admin-token-mint, checked-every-call cost, live perm updates, model-
  trust climax. 2037 words, 0 em-dashes, re-PUT to the draft. notes.md fragments now partly stale
  (the dual-key ones) — draft.md is canonical.
- **STILL REQUIRED before going live:** (1) Saad's out-loud voice pass (checklist rule — do not
  autopilot-publish); (2) optional real rate-limit numbers (rate-limit section was also cut in the
  single-key rewrite — re-add only if real). Then flip published:true. After live: Medium import-from
  -URL + Hashnode manual paste w/ 1600 cover + canonical → dev.to.

## 2026-06-30 (session 6c — post 05 PUBLISHED LIVE)

- Heavy iteration on the mechanism with Saad before publish: (1) neutralized infra terms (tenant →
  account, container → its own environment) per IP rule; (2) cut the false "stateless vs revocable,
  pick one" tradeoff framing — the key is a placeholder so a live lookup is inherent, not a chosen
  cost; (3) added "third-party" to explain why the three services had clashing credential models;
  (4) re-added the TWO-TIER key model (access key = the mock/placeholder used per call; refresh key =
  saved, scoped only to refresh, mints new access keys); (5) made the PROXY + MIDDLEWARE-SWAP explicit
  (agent calls our proxied endpoints with a mock API key, middleware swaps it for the real credential,
  calls the real service, returns data; agent can't tell) + the disposability payoff (kill the mock
  key anytime without rotating the real key); (6) corrected the permission model — permissions live
  with the USER (single source of truth), the key is pure identity, read per-call, so promote/demote
  needs zero propagation.
- **PUBLISHED to dev.to** (id 4024982, published_at 2026-06-30T16:01Z):
  https://dev.to/abdullahsaad5/my-agent-kept-reading-data-it-wasnt-allowed-to-the-prompt-was-never-going-to-stop-it-564k
  Title: "My agent kept reading data it wasn't allowed to. The prompt was never going to stop it."
  Note: published WITHOUT the usual out-loud voice pass, at Saad's direct instruction; justified
  because he supplied + corrected every claim live across the session (can defend it). draft.md +
  devto.md in sync, 2491 words, cover wired (cyan single-key art).
- **TODO next:** Medium import-from-URL (canonical auto → dev.to), then Hashnode manual paste w/
  1600 cover + canonical → dev.to. Optional: regen cover line ("one key" vs the two-tier reality).
  Capture any comments in feedback-log.

## 2026-06-27 (session 5 — post 04 revisions, post 02 reply, spoken-voice mining)

- **Post 04 critique + revision** (Saad asked "what's not good"). Closed the asserted-but-unshown ending
  by planting a real "call the model couldn't make" — Saad's actual one: AI never even raised the
  mid-billing-cycle package-add (proration) and admin-side plan-change-for-existing-subscribers cases;
  the judgment (charge-now vs next-cycle, migrate vs grandfather) is the human call. Also: "harder
  feature" → "more moving parts", added a concrete "after" scene, trimmed the 4-gain run-on, softened
  the fragment cadence + the "tell good from generated" overclaim, "Claude" → "the model". Fixed a date
  error (ten years → four). All synced via PUT to dev.to 4000815 (still `published:null`).
- **Post 04 title — finalized after several rounds**: **"I'm shipping the best work of my career. None
  of it feels like mine."** Killed the "I build AI agents" vantage (spammy) and chair-jump titles.
- **Post 02 reply (round 4 → @jugeni's post-execution-gate point).** Iterated: rejected the
  human-review-the-diff close and the least-privilege idea; final reply keeps the delta-comparison +
  reversibility framings, admits no clean automated close, bounces the open question back to Mike.
  Voice-passed, 0 em-dashes, on clipboard (`scratchpad/post02-reply-3.txt`). Logged in feedback-log.
- **Spoken-voice mining (big one).** Converted all 37 `~/Downloads/1782557923882-scopien_team_sync_docs`
  docx to text, extracted Abdullah's verbatim turns from the "📖 Transcript" sections: **19 meetings,
  ~1,132 turns, ~13.8k words**. Read the whole corpus, added a **"Spoken voice"** section to
  `voice-profile.md` with concrete patterns + real quotes (reasoning-shape, "So" as load-bearing word,
  concrete-example reflex, justifies-by-use, comparison + honest quantifying, flat ownership, low-ego
  deference, fillers-to-strip, off-the-clock warmth). Corpus saved in scratchpad for re-mining.
- **Post 04 PUBLISHED LIVE on dev.to** (id 4000815):
  https://dev.to/abdullahsaad5/im-shipping-the-best-work-of-my-career-none-of-it-feels-like-mine-4ehn
  (gotcha: the publish PUT returned `published:null` but it actually went live; verify via
  `/api/articles/me/published`, not the PUT response.) **Cover**: generated a creative dark/gold
  brand-matched cover (`cover.html` to `cover.png`: Fraunces, hollow "mine.", grid texture, no platform
  branding so it works on Medium too); Saad uploaded it (S3 `2maqdwt8vfaa3cw8tcf8.png`), set via
  front-matter `cover_image` PUT. **Surfaced**: portfolio Selected writing (`abdullahsaad5.github.io`,
  pushed `e63a92a`, S3 cover thumb) and top of README writing list (`AbdullahSaad5-profile`, pushed
  `5888076`, rebased over a waka auto-update). Both SSH pushes OK.
- **Medium**: drafted subtitle + 5 tags (Artificial Intelligence, Programming, Software Engineering,
  Careers, Developer Experience). Cross-post pending; Saad imports from the dev.to URL (sets canonical),
  then sets subtitle/tags by hand (import doesn't carry them).
- **Hashnode added as a 3rd platform.** Going forward the per-post routine is **dev.to (canonical) +
  Medium + Hashnode, then surface on the profile README + portfolio site** (full checklist now in
  PLAN.md). Created publication `abdullahsaad5.hashnode.dev` ("Abdullah Saad"); generated an AS-monogram
  brand icon (`blog/hashnode-icon.png`). Hashnode's GraphQL API (`gql.hashnode.com`) is now **Pro-gated**
  (free plan can't use it), so cross-post is **manual via the editor**: generated body-only files per
  post (`posts/*/hashnode.md`) and a consistent **1600x840** cover set for 02/03/04
  (`posts/*/cover-1600.png`, ink+gold, hollow-word visual). Each Hashnode post needs tags + cover +
  **Canonical URL → its dev.to link**. Token in Keychain (`hashnode-api-token`). Cross-posting in
  progress (pushed bodies to clipboard one by one).

---

## 2026-06-26 (session 4 — post 04 grilled + drafted)

- **New post 04 chosen: opinion essay, "There's no joy in programming now" (pre-AI vs post-AI).**
  Saad killed the next-in-line technical pick (A3 in-chat preview) after we clarified that **plan-mode
  (02) got traction, doc-authoring (03) didn't** — traction driver is deep agent-systems/safety, and
  A3 is frontend polish. He then steered to a programming-route opinion piece instead. Logged to
  `PLAN.md` under a new "Standalone opinion posts" backlog section (not in `ideas.md` — that file is
  commit-sourced only).
- **Ran `grill-me`** (6 questions, one at a time). Mined into `posts/04-programming-joy/notes.md`:
  - Stance locked **(c) traded** — gains real, joy diminished not dead, loss = ownership + appreciation.
  - Beat 1 centerpiece: the **deal-jacket recursive pipeline** (junior dev, Route One), 4-day grind,
    jumped out of his chair. Plus the whiteboard / poking-holes-in-each-other's-logic loss.
  - Contrast: **Stripe-as-junior** (didn't know webhooks/race/dupe/stale) vs a **7-8 module billing
    system AI hardened in under a week** — felt almost nothing.
  - Human texture lost: teasing, rubber-duck, prod-outage adrenaline; Slack-tag-Claude pattern.
  - Real thesis: AI commoditized building → ownership + appreciation for craft died ("can't tell good
    from generated, so nobody values either"). Aimed **wide** (craft as a value), not personal credit.
  - Gains (un-grudged): 10x→100x, AI eats boilerplate so you start on craft day one, side projects ship
    + open-source, smaller client gap. Four confirmed adds: democratization-is-the-same-coin, AI-as-tutor
    (Stripe callback), killed-the-toil, cheap-curiosity.
  - Ending **softened** (not "crushed"): public scoreboard for craft is broken, but the private joy
    survives if you opt into the hard part on purpose.
- **Drafted `draft.md`** (~2045 words, ~8-9 min). Voice-profile enforced: **0 em-dashes in body**
  (verified), no AI-tell phrases. 4 title options in the draft's header comment.
- **Built `devto.md`** (front-matter: title #1, `published:false`, tags `ai, programming, career,
  productivity`, no series — standalone opinion piece, cover blank, canonical blank = dev.to canonical).
- **Staged on dev.to as a DRAFT** via `publish-devto.sh` (Keychain key). Article **id 4000815**,
  `published:null`. Not public — sits in the dashboard for Saad's review.
  URL (draft): https://dev.to/dashboard → the post titled below.
- **Still NOT live.** Per feedback-log voice-discipline rule, Saad does his out-loud voice pass + adds
  a cover in the editor, then flips `published:true` himself (or we PUT to `/api/articles/4000815`).

- **Editorial voice pass** (not a substitute for Saad's). Killed the self-referential windups Saad
  flagged on post 03 ("I want to talk about", "let me say the real thing", "I want to be honest about
  both edges", "I want to be clear about that") and one "it's not X, it's Y" header. **Fixed a factual
  error Saad caught: "ten years apart" → "four years" (2022→2026).** Re-verified 0 em-dashes, 0 windups.
  Synced to the dev.to draft via PUT to `/api/articles/4000815` (still `published:null`).

- **Critique + revision pass** (Saad asked "tell me what's not good"). Fixed: (1) the optimistic
  ending was asserted but never shown — planted a concrete "call the model couldn't make" in the
  billing section so the ending is earned; (2) "harder feature than the deal jacket" (contestable) →
  "more moving parts"; (3) the "after" was summary not scene → added a concrete moment mirroring the
  opening ("PR merged, checks green, closed the laptop. No chair. Nobody looked over."); (4) trimmed
  the 4-gain run-on paragraph to 2 (teacher + killed-the-toil); (5) softened the stacked punch-fragment
  cadence + the "tell good from generated died" overclaim; "talk to Claude" → "talk to the model".
  Re-synced to dev.to (PUT 4000815, still `published:null`). ~2022 words.

### Still open (session 4)
- ~~CONFIRM the planted judgment-call beat.~~ DONE. Saad gave the REAL one (better than my token-limit
  guess): the cases AI **never even raised** — buying a second package mid-billing-cycle (proration),
  and an admin changing a plan when people are already on the old one (what happens to existing subs).
  Rewrote the beat with this + the point that the model didn't surface the case at all; the judgment
  (charge-diff-now vs next-cycle, migrate-everyone vs grandfather) is the human call. Synced + PUT.
  (Still confirm the "closed the laptop / no chair" moment feels true.)
- **Saad's own out-loud voice pass** (the editorial pass is mechanical; the human pass is still
  required before going live — pure essay, authenticity is everything).
- **Add a cover** in the dev.to editor (API can't upload images), then **flip live** (PUT id 4000815
  with `published:true`, or toggle in dashboard).
- ~~Lock the title.~~ DONE, after iterations (2026-06-27): final title **"I'm shipping the best work
  of my career. None of it feels like mine."** (the ownership thesis). Dropped along the way: the
  "I build AI agents for a living" vantage (spammy + wrongly implied his built agent took his joy vs
  the AI he codes with) and chair-jump titles (chair imagery not good in a title). Body still opens
  with the chair scene; only the title moved off it.
- After voice pass: `edit-article` tighten → build `devto.md` (front-matter + cover) → publish via
  `publish-devto.sh` → cross-post Medium/portfolio card.
- (Carry-over) Rotate the dev.to API key; cross-post 03 to Medium; Saad to set GitHub bio.

---

## 2026-06-26 (session 3 — post 03 live + post 02 comment reply)

- **Post 03 published live.** Flipped `published: true` in `posts/03-doc-authoring/devto.md` and
  PUT to `/api/articles/3992063`. Live + cover intact:
  https://dev.to/abdullahsaad5/i-built-an-abstraction-so-my-agent-could-write-documents-then-i-deleted-it-5687
  (gotcha logged: in the PUT one-liner, set the key as a plain shell var, not a `VAR=val curl`
  prefix — the `${KEY}` header is expanded before curl runs, so the prefix form sends an empty
  api-key and 401s.)
- **Post 02 comment** — replied to @jugeni's 2026-06-26 follow-up (can both gates fail together on
  a framing attack). Answer: the classifier is the framing-independent check by construction (reads
  raw call form, not the prose/intent); residual = destructive-in-effect-but-benign-in-form on the
  raw-API tail, which falls to blast radius + human review. Drafted in Saad voice, 0 em-dashes,
  copied to clipboard for hand-paste. (Reminder: @jugeni still the suspect account — engaged on
  substance, not as validation.)
- **Post 03 surfaced on profile + portfolio.** Added it to the top of the Writing list in the
  README (`AbdullahSaad5-profile`, pushed `af46ffc`; rebase pulled in a WakaTime auto-update) and
  a new card atop "Selected writing" in the portfolio (`abdullahsaad5.github.io/index.html`, pushed
  `bd4cef2`). Cover thumb `gipm7eirj2jm8l9xq60q.png`. Both repos are SSH-only push (gh CLI = work
  acct, no write access to personal repos).
- **Medium preview copy drafted** for the cross-post: subtitle "A wrapper let my agent write a deck
  in five lines. It also made every deck look the same. Why I deleted the thing I spent weeks
  building." Topics: Artificial Intelligence, AI Agents, Programming, Software Development, Large
  Language Models. (Medium import does NOT carry subtitle/topics — set by hand after import.)

### Still open (session 3)
- **Post 03: cross-post to Medium** (Import-from-URL, canonical -> dev.to; needs Saad logged in).
  Preview subtitle + topics drafted above.
- Post 03 ending: optional, Saad may rewrite the close in his own words.
- **Rotate the dev.to API key** (re-exposed in chat 06-25). It's in Keychain now; rotate at dev.to
  then `security add-generic-password -a abdullahsaad5 -s dev-to-api-key -w 'NEW' -U`.
- Saad to set the GitHub bio (pick from options); optional: make WakaTime profile public.

---

## 2026-06-25 (session 2 — post 03 + profile rebrand)

**Post 03 (doc-authoring)** in `posts/03-doc-authoring/`:
- Picked **A2 "agent document authoring"** from the backlog. Spine = a reversal: built a wrapper
  (`scopien_docgen`) so the agent writes ~5 lines not a 5000-token script, then **deleted it**
  (Scopien commit `33303a8`) because it made every doc generic/templated. Core insight: a
  results-driven agent declares victory the moment a file exists; the wrapper was an exit ramp.
  Fix v2 = raw libs + a mandatory design brief + STYLING.md recipe + a self-review loop.
- Mined source from `~/Documents/DTCForceWork/ScopienOS/Scopien/` (docgen lib + skills) into
  `notes.md`. War stories: WeasyPrint emoji tofu, Deck.table auto-paginate, opaque xlsx ARGB +
  full-range autofilter, py3.11 f-string break, path-as-palette NoneType.
- Centerpiece before/after: rasterized two real billionaire decks (`soffice` -> `pdftoppm`),
  pulled interior slides as proof (`proof-table-dump/cont/chart.png`, `cover-before/after.png`).
  The wrapper's "(cont.)" table-overflow slide is the smoking gun.
- Drafted `draft.md` + `devto.md` (Saad voice, 0 em-dashes). Saad heavily directed: added the
  sunk-cost beat, the lower-customizability honesty, "accept criticism upfront", and "not against
  abstraction / building toward a better one". Removed AI tells (keep-coming-back-to,
  I-want-to-be-careful, sit-with-it, repeated I'd-rather). Added AI-tell research + a new
  self-referential-framing anti-pattern to `voice-profile.md`.
- **Published to dev.to as a DRAFT** (id **3992063**, `published:false`). Cover (chrome-headless,
  cream/gold) + 5 captioned inline images uploaded by Saad (S3 urls), wired via PUT. ~10 min read.
- dev.to API key moved to **macOS Keychain** (service `dev-to-api-key`); added memory
  `devto-publishing`. publish/update via `security find-generic-password ... | publish-devto.sh`.

**GitHub profile README rebrand** (repo `AbdullahSaad5/AbdullahSaad5`, cloned at
`~/Documents/Personal/AbdullahSaad5-profile/`, SSH-only push like the portfolio):
- Full AI-forward rebrand from badge-soup. Dual hero banners `banner-dark/light.png` via
  `<picture media="prefers-color-scheme">`. One screen, skillicons stack, **live WakaTime block
  kept** (waka action), Medium added, **email typo fixed** (`syedabdullahsaad1`), dry fun line.
  Pushed live (`542c0fc`). Memory `abdullah-profile` updated with the repo + banner workflow.
- **Portfolio**: added Medium to contact links, pushed (`79e80df`).
- Gave GitHub-bio options (self-deprecating set); Saad to pick + set it himself (gh = work acct,
  can't edit personal bio).

### Still open (session 2)
- ~~**Post 03: flip `published:true`.**~~ DONE 2026-06-26 (now live). Cross-post to Medium
  (Import-from-URL, canonical -> dev.to) and the portfolio card carry forward to session 3.
- Post 03 ending: optional, Saad may rewrite the close in his own words.
- **Rotate the dev.to API key** (re-exposed in chat today). It's in Keychain now; rotate at dev.to
  then `security add-generic-password -a abdullahsaad5 -s dev-to-api-key -w 'NEW' -U`.
- Saad to set the GitHub bio (pick from options); optional: make WakaTime profile public to swap
  the text block for a graphical live card.

---

## 2026-06-25
- **Confirmed post 01 + site live.** `abdullahsaad5.github.io` HTTP 200 and byte-identical to
  local (pushed, in sync). dev.to post 01 live. Site is a static `index.html` (Next.js/MDX blog
  still "Later"). Note: site dir has no local `.git` — was pushed from elsewhere.
- **Post 02 (plan-mode) raw material mined** via grill-me. Captured in `posts/02-plan-mode/notes.md`:
  3 redos (lived-in-main-agent → separate planner; planned-blind → research tools;
  too-eager → prefilled-recommended-answer questions), the two-agent context handoff, must/should/
  could criticality, evidence + abort/replan loop, two-layer destructive detection (intent + a
  command classifier, ~99% over 1200 commands), alias-per-step plan that closes post 01's gap.
  Open: DAG arrow direction unconfirmed.
- **Drafted** `posts/02-plan-mode/draft.md` (Saad voice, 0 em-dashes, ~2.6k words) and `devto.md`
  (front-matter, series, must/should/could table).
- **Cover**: generated `posts/02-plan-mode/cover.png` via headless Chrome (2000x840). Saad
  uploaded his own to dev.to instead (S3 url).
- **Published** post 02 to dev.to via API (id **3989731**) using `publish-devto.sh`; set cover_image.
- **Comments**: 2 readers. Drafted replies to both (in `scratchpad/replies.txt`); Saad posted them.
- **Honest review**: comments likely AI / growth-hack (esp. @jugeni); flagged the real issue =
  voice-pass discipline gap (post was AI-drafted and published on autopilot without Saad's pass).
- **Built the logging system**: `feedback-log.md` (reader feedback → lessons) + this worklog.
  Added memories `blog-voice-discipline` and `blog-ops-log`.

- **Added Medium as a cross-post target.** No API (retired ~2023) — use Medium Import tool
  (medium.com/p/import) with the dev.to URL; auto-sets canonical. Manual, Saad-driven.

- **Cross-posted BOTH posts to Medium** (handle now @abdullahsaad5, changed from @syedabdullahsaad1).
  Verified live + canonical points back to dev.to for both (Import tool set it). Replaced the broken
  tables with list/image (Medium has no tables); generated table images `posts/01.../table-modes.png`
  and `posts/02.../table-criticality.png`. Post IDs: post2 8f6d24a7455a, post1 46c788c6027b.

- **Portfolio site updated for post 02.** Made `abdullahsaad5.github.io/` a proper git repo wired
  to SSH remote `git@github.com:AbdullahSaad5/AbdullahSaad5.github.io.git` (history preserved via
  fetch+reset, not fresh init). Added post 02 card to the writing section, deployed (commit 38ec2b1).
  Removed orphan files from an old multi-file version (style.css, script.js, favicon.png,
  img/profile-picture-cropped.png) — repo now just .gitignore, .nojekyll, README.md, index.html
  (commit 6d8ffce). Live verified HTTP 200 with both posts. Note: push needs SSH (gh = work acct
  abdullahsaaddtc, read-only; SSH key = personal AbdullahSaad5). .nojekyll must stay (Pages safety).

### Still open
- Eyeball post 1 on Medium: confirm the 2nd mermaid diagram (alias/OS-isolation) rendered.
- Rotate the dev.to api-key (was pasted in plaintext during the session).
- Reconcile `draft.md` with the must/should/could table that's in the live version (canonical drift).
- Decide keep/delete `posts/02-plan-mode/cover.png` (Saad used his own upload).

---

### Template
```
## YYYY-MM-DD
- what we did, with file paths / ids so it's actionable later.
### Still open
- carry-forward items.
```
