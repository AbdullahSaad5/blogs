# Tech Blog Plan — Syed Abdullah Saad

_Planned 2026-06-24. Goal: job hunting (primary) + personal brand (secondary)._

## Lane
**Practical AI-in-real-products, full-stack flavored.** The dev who wires LLMs/agents
into apps that actually ship. Moat = ships hard full-stack product (MERN/Next, Plaid/
Stripe/bank integrations) AND builds with agents/local models (Qwen/Gemma via Ollama,
Claude/Codex). That overlap is scarce — lean on it.

## Locked decisions
| Branch | Decision |
|---|---|
| Platform | **dev.to = canonical home for now** (own Next.js/MDX blog still "Later"). **Cross-post every piece to Medium + Hashnode**, canonical → the dev.to URL. Hashnode is on the free plan, so cross-post is manual via its editor (its GraphQL API is now Pro-gated); Medium via Import-from-URL. So the publish set is **dev.to + Medium + Hashnode**. |
| Cadence | Weekly to launch → biweekly to sustain. Keep a 3-post buffer; always be one post ahead. |
| Anchor post | Lead with AI. The NL-CLI doing action-selection over 700+ apps + reusable flows. |
| IP rule | Never name employer / Activepieces. Methodology IS revealable. Abstract the company, not the engineering. Neutral example apps. |
| Workflow | Interview → outline + fragments → Saad writes technical spine in his voice → Claude tightens + flags weak claims → Saad final pass. |
| Distribution | Passive on LinkedIn (no posting yet). Active only on no-stakes channels: dev.to, Hashnode, r/LocalLLaMA, r/LLMDevs, X. |
| Sequence | Write first, build blog in parallel (one timeboxed weekend, proven MDX starter). No blog feature unless a post is blocked without it. |

## Backlog
_Full sourced/authorship-tagged list in `ideas.md`. Below is the running order._

1. CLI agent that operates apps — **anchor** (AI). Action-selection at scale + safe side-effect execution. DRAFTED (posts/01-agent-identity/draft.md).
2. **Plan mode** — agent plans steps first, classifies destructive steps, confirms them; planner/executor split; 3-layer read-only posture; what got torn out and redone. SEQUEL to #1, teased at end of anchor post. "The planning was harder than the doing." [Tier A, verified yours]
3. **Agent document authoring** — making an agent generate real docx/pptx/xlsx/pdf without writing 5k-token scripts or breaking; design-first; browser-free verification; the gotchas. [Tier A, very scarce]
4. **In-chat artifact/document preview** — server-rendered Office previews + memory-optimized PDF viewer inside a streaming chat UI without reloading on every token. [Tier A]
5. **Lazy-loading 280+ integration packages at runtime** — install-on-use, server-version anchoring, self-heal interrupted installs. [Tier A]
6. **Streaming sub-agent tool events** — quiet-vs-verbose agent narration in a chat protocol. [Tier B]
7. **Per-project quota/feature enforcement via embed JWT** — billing claims in the token, QUOTA_EXCEEDED to host. [Tier B]
8. **Agent key exchange** — self-refreshing short-lived credentials for autonomous containers; a leaked key can't mint authority. [Tier A, scarce security post — strong contender to pull up to #3]
9. **Resumable SSE via Redis stream replay** — survive browser disconnects mid-stream. [Tier A, clean reusable infra]

### Standalone opinion posts (not commit-sourced — a different lever: traction + brand)
- **"There's no joy in programming now" — pre-AI vs post-AI.** Opinion essay. The demands then vs
  now, what we have to do to meet them, the lost problem-solving satisfaction, grounded in real
  experience. Vantage/hook = *the person who builds the AI agents* saying what they cost (insider, not
  bitter outsider). Spine: pre-AI demand + where satisfaction lived → post-AI demand flip (velocity,
  orchestrate + review, spec-not-solve) → what we now do to meet it → the honest cost → verdict.
  RISK: job-hunt optics — land the ending as a clear-eyed *trade* (lose X, gain Y, my stance), NOT
  pure elegy, so it reads self-aware + adaptive, not burned-out. MUST be Saad's words / real stories
  (pure essay, authenticity is the whole thing). In `posts/04-programming-joy/`. [grilled + drafted
  2026-06-26 — stance locked (c) traded; needs Saad voice pass before publish] PUBLISHED.
- **"How to think like a senior engineer" — seeing beyond what's in front of you.** Opinion essay.
  Not about title/years; about the habit of thinking past the immediate change: the second-order
  effects, the failure modes nobody asked about, the blast radius, what breaks at 10x, who else
  touches this. The senior move = reasoning about what you *can't* see in the diff. Vantage/hook =
  insider who ships agent/full-stack systems where the unseen case is the one that bites. Ground in
  real Saad stories (the key-exchange "leaked key re-mints itself forever" catch is a perfect
  example of seeing the hole before it ships; plan-mode destructive-step classification; the
  proration/grandfather cases AI never raised from post 04). RISK: don't preach — show the habit
  via concrete moments where thinking-beyond caught something, not a listicle of virtues. Same
  brand as post 04: real practitioner, defend every claim live. [idea logged 2026-06-29]
- **"Why two tokens? OAuth access vs refresh, explained by someone who was confused by it."**
  Explainer (teach-from-experience lever, not pure opinion). The access/refresh split confused Saad
  for a long time: why not one token? what does the second one buy? It only clicked when he built
  the agent key-exchange (post 05) and hit the exact problem the two-token design solves: you want a
  token short-lived enough that a leak dies fast, but you can't make the user re-auth every 7 days,
  so a second longer-lived token does nothing but mint fresh short ones. Short access = small leak
  blast radius; long refresh = no human in the loop. Hook = the confusion is the relatable on-ramp;
  the build is where it resolved. Tight sibling to post 05 — could ship right after it. [idea logged
  2026-06-29]

Later / proof-of-depth (from CV, pre-LLM): Plaid + bank API in a car-financing flow; the 11-actor
dealership system; local LLMs (Qwen/Gemma on Ollama). Use these to prove you ship hard product, not
just AI tinkering.

## First 3 actions
1. This week — interview loop on anchor post #1, get a draft spine.
2. One weekend, timeboxed — scaffold blog from proven MDX starter, deploy to Vercel. Minimal.
3. Bank post #2 (Ollama) — build the buffer before publishing #1.

## Publish + distribute (per post)
1. **dev.to** (canonical) — `publish-devto.sh`, add cover in editor, flip `published:true`.
2. **Medium** — Import-from-URL (auto-sets canonical → dev.to); set subtitle + tags by hand after.
3. **Hashnode** — manual New Article (free plan, GraphQL API is Pro-gated): paste `posts/NN/hashnode.md`,
   add tags + 1600x840 cover + set **Canonical URL → the dev.to link**.
4. **GitHub profile README** (`AbdullahSaad5-profile`) — add a bullet at top of Writing; SSH push.
5. **Portfolio site** (`abdullahsaad5.github.io`) — add a card atop Selected writing (S3 cover thumb); SSH push.
6. Optional active distribution: Hacker News, r/ExperiencedDevs (+ r/LocalLLaMA/r/LLMDevs for technical
   posts), X/Bluesky, LinkedIn (lean in for job-hunt).

Covers: keep the consistent 1600x840 ink+gold brand template (hollow-word visual, signature line),
generated via headless Chrome. The dev.to S3 cover URL doubles as the website card thumbnail.

## The one rule
**Writing > framework.** Don't let blog-tinkering eat the momentum. Ship posts, not config.

## Open item
Confirm employment contract allows personal open-source — only matters if Saad later
decides to expose a public version of the CLI tool (currently kept abstract).
