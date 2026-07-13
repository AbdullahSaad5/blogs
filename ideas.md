# Blog Idea Backlog — sourced from Saad's OWN commits

_Filtered to commits authored by `abdullahsaaddtc` / `abdullahsaad5` across the ScopienOS
repos (black-box, Scopie, Scopien, ScopieFlows). Team/upstream work excluded on purpose —
this blog only covers what Saad personally built._

Commit footprint: black-box 1781, Scopien 158, ScopieFlows 113, Scopie 79.

IP rule (same as always): never name the employer, the platform, or the upstream tools
(it's a fork of an open-source agent CLI + an open-source workflow engine — do not name them).
Methodology and technique are fair game. Example app names (Gmail, Salesforce) are fine.

---

## Tier A — clearly yours, strongest posts

### A1. Plan mode  (= planned post 02)
Agent plans all steps first, shows them, confirms destructive steps. Planner/executor split
sharing one chat thread via threadId. `submit_plan` / `ask_questions` / `step_update` tools.
CLI-aware read/write gating. Main agent denied plan-authoring tools. 3-layer read-only posture.
- War stories: v1 single runtime guard missed newly-added mutating tools; shared verb classifier
  in v2 so adding a tool updates one file and both layers inherit it. auto-emit awaiting_checkpoint.
- Source: Scopie `src/agents/tools/{submit-plan-tool,ask-questions-tool,sessions-spawn-tool}.ts`,
  `src/agents/pi-tools.before-tool-call.ts`; Scopien `agents/planner/{SOUL.md,AGENTS.md,AGENT.md}`;
  black-box `src/components/plan-dock.tsx`.
- IP difficulty: medium.

### A2. Agent document authoring — generate real docx/pptx/xlsx/pdf
Built `scopien_docgen` helper lib so agents emit short scripts, not 5k-token ones. Design-first
authoring skills (docx/pptx/xlsx/pdf), html-to-pdf (WeasyPrint), office-editor, diagram-author,
browser-free structural verification of Office files.
- War stories: "harden builders against the misuse that broke the agent"; WeasyPrint gotchas
  (no emoji, inline SVG icons, build-once); Deck.table auto-paginates long tables (no off-slide
  overflow); opaque xlsx colors + full-range autofilter; pdf colgroup f-string broke build on 3.11.
- Source: Scopien `skills/{docx,pptx,xlsx,pdf}-author/*`, `skills/*/STYLING.md`,
  `skills/html-to-pdf`, the scopien_docgen lib.
- IP difficulty: low. Very scarce, very Saad.

### A3. In-chat artifact / document preview inside a streaming chat UI
Server-rendered Office previews + memory/network-optimized PDF viewer, resizable artifact rail,
jump-to-message, artifacts tracked to originating message id — all without breaking the live stream.
- War stories: "stop open artifact reloading on every chat stream token"; "gate PDF ResizeObserver
  on contentReady"; "let preview stage shrink and raise min panel width"; glass surfaces vs flat.
- Source: black-box `src/components/{message-bubble,chat-area,message-input}.tsx`,
  artifact rail/stage components, `src/contexts/chat-provider.tsx`.
- IP difficulty: low.

### A4. Lazy-loading 280+ integration packages at runtime
Each integration is an npm package, installed on first use. TTL disk cache, version anchored to
the server-registered version (not npm-latest), concurrent-safe install locks, self-heal of
interrupted installs.
- War stories: "self-heal ENOTEMPTY from interrupted piece installs"; "pin flow pieces to the
  server's registered version"; "harden CLI against agent-operation failure modes".
- Source: ScopieFlows `packages/agent-cli/src/lib/runtime/{piece-install,cache,piece-resolver}.ts`.
- IP difficulty: low (don't name the upstream engine).

### A5. Agent key exchange — self-refreshing credentials for autonomous containers
Long-lived agent containers must refresh their own API credentials with no human in the loop, but a
leaked agent key must NOT be able to mint new authority. Solved with a tenant-scoped gateway token
(injected at provision) as the exchange credential; short-lived access key + rolling refresh with
file-based state; proactive refresh before expiry, reactive on 401; live RBAC re-check at request
time; cascade revoke on member-removal/disable/delete; per-user quota + revocation feature gate.
- War stories: v1 protocol REWRITTEN to "short-lived pair + auto-refresh"; "close two-gate gaps in
  scopieflows + crm/provision"; review findings M1–M3; "pin workspace per key kind + route CRM
  through user creds"; "treat empty projects.* permissions as module revocation".
- Source: black-box agent-keys CRUD/routes/verification, `docs/AGENT_KEY_EXCHANGE.md`,
  `docs/AGENT_KEY_PROTOCOL.md`, `docs/AGENT_API_KEYS.md`.
- IP difficulty: medium. Deep, scarce security/systems post — fully yours (Apr 22–26 + May hardening).

### A6. Resumable SSE via Redis stream accumulation + replay
Status streams over SSE for 5–60s (provisioning, later agent chat); browser disconnects lose progress.
Every event XADD'd to a Redis stream; on reconnect replay missed events (exclusive of last-seen id)
then subscribe live; if already finished, serve the terminal snapshot. `useResumableStream` hook;
`drainOneEvent`/`ensureDrainTimer` SSE handling; TTL lifecycle (active vs terminal). Later reused to
"retain tool calls in Redis hot buffer for reconnection".
- War stories: SSE refactor consolidating drain logic; reconnect-attempt handling; plan-mode
  "exhaustive event-replay hardening"; "reconcile a settled plan the run-finished gate missed".
- Source: black-box provision-stream route, `useResumableStream` hook, `docs/RESUMABLE_STREAMS.md`.
- IP difficulty: low. Clean reusable infra pattern — yours (Feb 26 onward).

---

## Tier B — mostly yours

### B1. Streaming sub-agent tool events + quiet-vs-verbose agent narration
Forward sub-agent tool events to the parent client; separate working-narration from final answers
in the chat protocol; kill assistant-text duplication at the producer; firehose cap for operator
observers.
- War stories: revert of "separate working narration" then re-do block-aware merge; register
  tool-event recipient up front to fix quiet-mode streaming; retain sessionKey for sub-agent runs.
- Source: Scopie `src/gateway/{server-chat,server-methods/chat}.ts`, `src/infra/agent-events.ts`.
- IP difficulty: low.

### B2. Per-project quota & feature enforcement via embed JWT
Hard-enforce per-project quotas/features across the API; carry quota/feature claims in a v3 embed
JWT; propagate QUOTA_EXCEEDED into the embedded app and to the host; per-user ownerId scoping for
CLI principals; rollback optimistic apply when server rejects.
- Source: ScopieFlows `packages/server/api/src/app/ee/managed-authn/*`, billing project_plan
  entity + migrations, `packages/web` QUOTA_EXCEEDED handler.
- IP difficulty: low-medium.

### B3. Agents composing reusable flows (vs firing one action)
LLM authoring reusable flows through the CLI: resolve connection before installing pieces, default
omitted optional props, smoother flow authoring anchored to server version.
- Note: distinct from the anchor post (which is single-action firing). This is flow *composition*.
- Source: ScopieFlows `packages/agent-cli/src/lib/runtime/flow-builder/*`, `commands/{action,flows}.ts`.
- IP difficulty: low.

### B4. Cache write policies — write-through vs write-back vs write-around
The three ways a cache handles writes, and when each is right: **write-through** (write cache + backing
store together — safe, slower writes), **write-back / write-behind** (write cache now, flush to store
later — fast, risks loss on crash), **write-around** (write straight to store, skip cache — avoids
polluting cache with write-once data). Tie to the real TTL disk cache in A4: why version-anchored
piece installs use a read-through pattern, where write-back would've corrupted on the interrupted-install
crashes, and how the self-heal logic is really a consistency story.
- Source: anchor to ScopieFlows `packages/agent-cli/src/lib/runtime/{cache,piece-install}.ts` (the A4 cache).
- IP difficulty: low. Concept post grounded in your own cache code.

---

## Tier C — partly yours, VERIFY depth before committing

- **C1. Cross-tenant artifact self-heal as accepted security debt** (black-box files/drive). Recovering
  artifacts from orphaned tenant buckets, reverting cross-tenant read, logging accepted debt. Honest
  security war story but sensitive — handle the cross-tenant angle carefully or abstract hard.
- **C2. Twenty-CRM self-heal / redirect-loop fix** — "self-heal stale Twenty subdomain instead of
  looping"; provisioning sessionKey fixes; tenant readiness reconciliation.
- **C3. Context injection / chat resume** via `src/lib/chat-sync.ts` (touched 30x) — verify how much
  of the summarize-and-inject design is yours vs team.
- **C4. Command-classifier hardening** (Scopien) — quote/heredoc-aware classifier, recon-pattern
  matching at command position. Security-flavored, partly yours.
- **C5. The projects skill as generated agent-cli actions** — 44 fine-grained actions then collapsed
  to six lumped ones (v0.13 → v0.14). Codegen + API-shape-design war story.
- **C6. Command-classifier hardening** (Scopien security) — "match recon patterns at command position;
  quote/heredoc-aware classifier". Your security contribution on top of the classifier.
- **C7. Injecting platform secrets into an agent's process.env + entitlement-gated skill loading** —
  `agent-cli envOverrides` to inject platform secrets; `sync-sf-skills.sh` vault that hard-gates
  Salesforce skills by billing/image. Secrets-handling for agents, yours.
- **C8. AI run-summaries / agent-log observability** (cortex-comms) — Grok summary of the planner
  trace, lead-centric run summaries, regenerate-always-re-runs-summary. Different from context-injection.
- **C9. White-labeling a multi-tenant SaaS per client** — the NXFA (Nexus One) full rebrand. Theming/
  branding a product for a client. Yours, low IP risk if generalized.
- **C10. QuickBooks OAuth connect flow + admin UI** — small but clean real-OAuth-integration post.

---

## Discarded (genuinely team / upstream — NOT Saad's, do not write as his)
_Re-audited against authorship. These remain team/upstream:_ guardrail PIPELINE internals (you only
hardened the classifier — see C6), Docker sandbox / fs-bridge / path-safety internals, the exec-approvals
system, plugin loader / jiti, model failover / provider registry, security-audit policy, the upstream-sync
AUTOMATION tooling (rename-upstream etc.), the Salesforce multi-auth piece, turbo-monorepo / engine /
piece-framework, file-lock concurrency + circuit-breaker (Scopien infra), Salesforce 45-skill decomposition.

_Corrected out of this list (they ARE yours): Agent Key Exchange → A5, Resumable Redis Streams → A6._

> NOTE on method: the first pass ranked authorship by file-touch frequency, which missed concentrated
> bursts of deep infra work (A5/A6 were both short, dense pushes). If any other "discarded" item feels
> like yours, say so and we'll git-verify it — don't trust the frequency ranking alone.
