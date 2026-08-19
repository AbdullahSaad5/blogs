# Blogs

<!-- repo-hygiene: reposhuttle-standard -->

**Collection of static blog pages and writing experiments.**

## Overview

Collection of static blog pages and writing experiments.

This README records the repository's purpose, verified local workflow, major technology choices, and maintenance status so the project can be understood without first reverse-engineering the source tree.

## Highlights

- Implementation centered on HTML
- Source and supporting project assets kept together for reproducibility

## Tech stack

HTML

## Quick start

Clone the repository, then use the build or run instructions provided by the project files.

## Configuration

No repository-specific configuration file is required for the basic workflow documented above.

## Project structure

```text
pages/  # page-level routes or views
```

## Repository status

This repository is maintained as a project reference and portfolio artifact.

## Development

Before submitting a change, run the project's available build or execution workflow and verify the affected behavior manually.
Keep changes focused, avoid committing generated artifacts unless the project already tracks them, and update this README whenever setup or behavior changes.

## Security and configuration hygiene

Keep secrets in local environment variables or an ignored `.env` file. Never commit API keys, access tokens, private keys, production database URLs, or customer data. If a credential is committed, revoke and rotate it; deleting the file in a later commit does not remove it from Git history.

## Contributing

Open an issue or provide context before making a large change. Prefer small pull requests with a clear purpose, verification notes, and screenshots for visible UI changes.

## Additional project notes

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

| # | Slug | Title | Status |
|---|------|-------|--------|
| 01 | agent-identity | Why my AI agent kept writing to the wrong client's Salesforce | ✅ Published |
| 02 | plan-mode | The hard part of my AI agent wasn't doing the work, it was planning it | ✅ Published |
| 03 | doc-authoring | I built an abstraction so my agent could write documents. Then I deleted it. | ✅ Published |
| 04 | programming-joy | I'm shipping the best work of my career. None of it feels like mine. | ✅ Published |
| 05 | agent-key-exchange | My agent kept reading data it wasn't allowed to. The prompt was never going to stop it. | ✅ Published |
| 06 | two-tokens-oauth | Access vs Refresh Tokens: I Was Missing Two Ideas | ✅ Published (dev.to live 2026-07-13) |

All live on [dev.to](https://dev.to/abdullahsaad5). See `PLAN.md` for the full backlog and the
reasoning behind every decision.

## License

No license file is currently included. Unless the repository owner states otherwise, the source is not offered under an open-source license.
