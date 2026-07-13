# Anchor Post #1 — Raw Material + Outline

_Working title options:_
- "How I stopped an AI agent from acting on the wrong account"
- "Session-scoped identity: the bug that taught me not to trust LLM memory"
- "Letting an LLM run real actions across hundreds of apps — the hard parts"

**IP rule:** never name employer or the workflow platform it's built on. Example app
names (Gmail, Salesforce, Outlook) are fine — generic SaaS, not employer IP. Abstract
the company, not the engineering.

---

## The spine (narrative order)

### 1. Hook — the real hard problem
An LLM that runs *real* actions across 700+ apps. The hard part isn't calling an API.
It's **which action** and **which account** — when the user has many connections and
the model has a memory.

### 2. Action-selection at scale
- 700+ app repo. Each app has metadata describing what it's for.
- Explicit: user names the app → direct lookup.
- Implicit: LLM keyword-searches app metadata.
- **The sharp idea — connections as the narrowing signal:** only consider apps the user
  has actually connected (encrypted, stored). "Send email" + a Gmail connection on file
  → target known. No connection → ask to connect first. The authorization graph collapses
  a 700-app search space.
- Multiple matching connections → agent asks which.

### 3. The grounding ritual (determinism around a non-deterministic model)
A skill enforces a fixed sequence every time:
install app (or detect already installed) → probe manifest → list actions+descriptions
→ pick action → probe required props → fill props → call.
Lazy load: custom integration npm package downloaded on demand.

### 4. Custom-API fallback (never hard-fail)
If no coded action matches, agent makes a raw REST call on the *same connection*.
Graceful degradation — a missing integration doesn't kill the task.

### 5. CLIMAX — the cross-tenant bug + the fix
**Before:** A user managing multiple clients had several Salesforce connections.
Session A: picked connection for Client X, asked for custom fields + Apex.
Session B: picked a *different* connection, asked for LWC work — but the agent started
working on Session A's connection (pulled the old connectionId from persistent LLM
memory). User had to interrupt and manually fix the Salesforce org it wrongly touched.
Root cause: **persistent LLM memory + persistent connectionIds → cross-session bleed.**
Stable identifiers leaked into memory and resolved to the wrong account.

**Fix — session-scoped aliases:**
- Agent only ever sees aliases: `gmail-1`, `salesforce-2`. Never raw connectionIds.
- Same alias resolves to *different* real IDs in different sessions → memory can't bleed.
- Resolution is server-side: command carries the session id; mapper resolves
  `alias + sessionId → real connectionId` where the command executes.
- **OS-level isolation:** agent runs in restricted Linux perms; the mapper file is owned
  by a different user, so the agent literally cannot read it. It calls a function that
  spins a worker with read access. Even a misbehaving/compromised agent can't reach raw IDs.

### 6. Takeaways (what readers steal)
- Don't let stable identifiers leak into LLM memory across sessions — scope identity to
  the session via aliases.
- Wrap non-deterministic models in deterministic rituals.
- Narrow huge action spaces with the user's authorization graph, not brute force.
- Defense in depth: the agent can't do the wrong thing because it can't *see* what it'd need to.

## Honesty flag (handle in the post)
No confirm gate — it just fires (deliberate: user already stated intent, keep them out of
the loop for speed). Frame as a conscious tradeoff. Safety story = grounding ritual +
alias isolation + same-connection fallback. Note a confirm gate is available as an option.
Owning the tradeoff reads senior; pretending it's flawless reads junior.
