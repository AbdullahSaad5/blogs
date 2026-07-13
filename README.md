# Blog

Technical blog. Goal: job hunting (primary) + personal brand (secondary).
Lane: practical AI-in-real-products, full-stack flavored.

## Structure

```
blog/
├── README.md            you are here
├── PLAN.md              master plan: all locked decisions + backlog
├── voice-profile.md     how Saad writes. EVERY draft runs through this.
└── posts/
    └── NN-slug/         one folder per post
        ├── notes.md     raw material from the interview (the quarry)
        ├── draft.md     the shaped article (canonical source)
        └── devto.md     publish-format copy (frontmatter + Mermaid diagrams + tables)
```

## Per-post workflow

1. **Interview** — Claude grills the experience out of Saad (the war stories, the
   failures, the guardrails). Output lands in `posts/NN-slug/notes.md`.
2. **Shape** — grow the article paragraph by paragraph into `draft.md`, pulling from
   notes, arguing format at each step. Runs through `voice-profile.md`.
3. **Edit** — `edit-article` pass: tighten, kill flab, flag weak/unprovable claims,
   check for employer-IP leaks and AI tells (no em-dashes).
4. **Title** lock.
5. **Publish** — own Next.js blog (canonical) + cross-post dev.to/Hashnode with
   `rel=canonical`. Active distribution on no-stakes channels only (dev.to, Hashnode,
   r/LocalLLaMA, r/LLMDevs, X). LinkedIn stays passive for now.

## Posts

| # | Slug | Status |
|---|------|--------|
| 01 | agent-identity | ✅ Done — "Why my AI agent kept writing to the wrong client's Salesforce" (ready to publish) |
| 02 | plan-mode | Planned (sequel teased in 01) |

See `PLAN.md` for the full backlog and the reasoning behind every decision.
