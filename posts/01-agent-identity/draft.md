# Why my AI agent kept writing to the wrong client's Salesforce

So one of my users pings me mid-task, a little panicked, because the agent is writing an Apex trigger into the wrong client's Salesforce.

He handles a bunch of clients, one Salesforce account each. In one session he picks a connection and asks for some custom fields. Next session he picks a *different* connection and asks for an LWC component, and the agent goes right back to the first account and starts working there instead. He had to interrupt it and manually undo what it touched on a client's live org.

Here's the thing everyone gets wrong about agents that take real actions: they think the hard part is wiring up the integrations. It's not. Wrapping an API is tedious, not hard. The hard part is the model getting two things right every single time: *which action*, and *which account*. And the fix for the second one wasn't a better prompt. It was realizing an LLM with a memory can't be trusted to remember who it's working for.

## What the thing actually is

So what is this thing. It's a CLI where you type a sentence and an LLM picks one action out of hundreds of apps and just runs it. Send the email, create the Salesforce field, pull the QuickBooks invoice, write the doc. Real actions on your real accounts, no clicking through a UI, no confirmation step. You say what you want and it goes and does it. Making that part work took an afternoon. Making it not do the wrong thing took months, and most of those months went into the two questions from up top.

## Which action

Start with the obvious problem. You've got 700 plus apps, and each one has a pile of actions. Gmail alone has send, draft, search, label, reply, the list goes on. Multiply that across every app and you're looking at thousands of possible actions. The naive thing is to hand all of them to the model and say pick one. That doesn't work. You blow the context window before the user even finishes their sentence, and even if it fit, the model gets worse at choosing the more options you give it, not better.

So the real question isn't "can the model pick an action." It's "how do you get it down to a handful of candidates before it has to pick at all."

There are two cheap ways to narrow it. If the user names the app, you're done, you look it up directly. If they don't, every app carries a bit of metadata describing what it's for, and the model can keyword-search that to find likely apps. A request about "email" pulls up the mail apps and ignores the other 690.

But the real narrowing comes from something most people skip: connections. Before the agent can touch an app, the user has to connect it, which means authorize it, and we store that connection encrypted. So at any point we know the exact set of apps a user has actually wired up, which is usually five or ten, not seven hundred.

Now "send an email" stops being a search across every mail provider in existence. If the user has a Gmail connection on file and no other mail app, there's nothing to guess, that's the one. No connection that fits the request at all, and we don't hallucinate one, we just ask them to connect something first. The authorization graph does most of the narrowing for free, because the user already told us what they use the day they connected it.

The one case left is when a user has more than one connection that fits, like two Gmail accounts or three Salesforce orgs. Then the agent asks which one, unless the user already said. Hold onto that case, because it's where everything later goes wrong.

## The ritual around the model

Once the agent knows the app, picking the action inside it is a fixed ritual. There's a skill that grounds the agent to always run the same sequence, every time, no improvising. Install the integration package if it isn't already there, and these are our own packages per app, so it lazily downloads the one it needs. Read that package's manifest. List the actions it exposes and their descriptions. Pick the one that fits the request. Probe that action for the props it requires. Fill the props. Call it.

Same dance, every single time. The point of the ritual is determinism wrapped around a thing that is not deterministic. The model still does the choosing, the part you can't make deterministic, but it chooses inside rails that never move. It can't skip the manifest and guess an action name, because the only actions it ever sees are the real ones the manifest just handed it.

## When there's no action for it

Sometimes we just haven't built an action for the thing the user wants. Instead of failing there, every app also exposes a raw API call on the same connection. So if no prebuilt action fits, the agent can make a direct REST call using the credentials the user already authorized. A missing integration doesn't hard-fail the task, it degrades to hitting the API directly. It means the long tail of stuff we never got around to coding still works, as long as the underlying app has an endpoint for it.

## Two modes, and the tradeoff between them

You might be wincing at the "no confirmation step" thing. That's only one of the two ways you can run it.

There's a direct mode, which is the one I've been describing. You say what you want and it just does it, no questions asked. The user already told us what they want, and sticking a yes-or-no in front of every single action kills the entire reason you'd use a thing like this. That's the fast, get-out-of-my-way mode.

And there's a plan mode, for when the stakes are higher. The agent plans out all the steps first and shows them to you before it touches anything, so you can read exactly what it's about to do and sign off. On top of that, every destructive step asks again right before it runs, so you know what you're getting into at the moment it matters, not after. It's slower, but you're actually in the loop.

In direct mode the safety can't come from asking permission, because there isn't any. It comes from the rails. The grounding ritual is one rail. The other one, the one that actually mattered, is how the agent handles identity, which is the part I want to get to, because that's where it bit me.

## Which account

Back to the panicked user and his Apex trigger in the wrong org.

The agent keeps a memory across sessions. That's a feature, it's how it remembers context and what you've done before. And every connection has a persistent id in the database, a stable connectionId we use to pull it back out. Both of those are reasonable on their own. Together they caused the bug.

Here's what actually happened under the hood. In one session he worked on Client A, and the connectionId for A landed in memory. In the next session he explicitly attached the connection for Client B and asked for the LWC work. But memory still held A's connectionId from before, and the model, doing what models do, pulled that id back out of memory and used it. Sometimes it would even fire on both, the one he attached and the one it remembered. A stable identifier leaked across a session boundary through memory, and the agent acted on a client's live org that the user never pointed it at.

You can't fix that by telling the model to be careful. The id is right there in its memory, and it has every reason to think it's relevant. So we took the ids away from it entirely.

The model never sees a real connectionId anymore. It sees aliases. `gmail-1`, `salesforce-2`. That's all it ever works with, and all the CLI commands take aliases too, so there's no path where it touches a raw id. The trick that makes this work is that the same alias resolves to a *different* real id in different sessions. `salesforce-1` today is not `salesforce-1` from last week. Resolution happens server-side, where the command actually runs: the command carries its session id, we know which real connection that session's `salesforce-1` maps to, and we swap it in at the last moment.

So even when memory drags an old `salesforce-1` into a new session, it's harmless, because in this session that alias points wherever this session says it points. Memory can't bleed an identity across sessions when the thing it remembers doesn't mean the same thing twice.

Then we went one step further, because I didn't want to just trust that the model wouldn't go hunting for the real ids on its own. The agent runs as a restricted user on Linux. The mapper that turns aliases into real connectionIds is owned by a different user, and the agent's user can't read it. The agent just calls a function, and that function spins up a worker with the right permissions to do the lookup and come back. So even if the model decided to reach around the alias and grab a real id, it can't read the file that would let it. It doesn't have the keys, at the OS level, not the prompt level.

## Where this still falls short

I want to be straight about what this does and doesn't buy you, because it's easy to read all that and assume the thing is locked down. It isn't.

What it buys you is that identity can't bleed across sessions anymore, and that's the whole bug I started with. There's a smaller worry you might have spotted, which is that the real id sometimes leaks back into the agent's context anyway, in an API response or a resolution step. That turned out not to matter, because the CLI doesn't accept raw connection ids at all. The only way to act on a connection is through its alias, and aliases only exist for the connections you've got in this session. So even when the model sees a real id, there's no command that takes it. The id is just trivia. The capability is the alias, and the alias is scoped to the session.

What the alias work does not protect against, on its own, is the model picking the wrong alias inside a single session. If `salesforce-1` and `salesforce-2` are both connected right now and the model confidently grabs the wrong one, you're back to the wrong-org problem, same outcome, different cause. The disambiguation only fires when the model knows it's unsure, and a confidently wrong model doesn't ask. This is exactly what plan mode is for. You see every step before it runs, including which account it's about to touch, and every destructive step asks again, so a wrong pick surfaces in front of you instead of in your client's live org. In direct mode you don't get that, so direct mode is where this risk actually lives.

And the bigger gap is prompt injection. The agent reads emails, docs, pages. If any of that content carries instructions, the agent will act on them using the connections it already has. It's not breaking out of anything, it's using the access you gave it, phrased by someone else. The alias system and the OS isolation do nothing here, because nothing about this involves a raw id or another session. Plan mode softens it, because an injected destructive action still has to clear the same confirmation as any other destructive step, and you'd see it before it ran. But in direct mode there's no human between a poisoned doc and a live write, and that's the part I'm least comfortable with. It's the next thing on the list.

So the honest version is this. The identity work kills one specific, real class of bug, accidental confusion from memory, and it kills it well, in both modes. The wrong pick and the injection problem are real, and plan mode is the answer for them today, with a human reading the plan and signing off on the destructive steps. Direct mode trades that oversight for speed, and if you're reading untrusted content in direct mode, you're trusting the model more than I'd want to. Pick the mode for the stakes.

## What I took from it

A few things stuck with me after all this.

Don't let stable identifiers leak into an LLM's memory. If something is going to persist across sessions, and an identity absolutely should not, scope it to the session and hand the model a name that only means something inside that session. The alias isn't a cosmetic wrapper, it's the actual fix.

Wrap the non-deterministic part in a deterministic ritual. The model choosing an action is the part you can't pin down, so pin down everything around it, and make the only options it sees the real ones.

Narrow huge spaces with what the user already authorized, not with brute force. The connection graph was sitting right there telling us what mattered, and it did more to make action-selection work than any prompt engineering did.

Make the right thing structural instead of asking nicely. The agent can't bleed an identity across sessions, not because we told it to be careful, but because the only thing it can act through is a session-scoped alias, and a stale alias means nothing in a new session. That's a real guarantee, but a narrow one. It covers accidental confusion from memory and nothing more. For the threats it doesn't cover, a confidently wrong pick inside a session, or an instruction smuggled in through content the agent reads, you need other layers, and honestly a human in the loop is one of them. Structural beats polite, but only for the exact thing you made structural.

I keep mentioning plan mode like it's a footnote, but it isn't, it's its own piece of engineering. How it lays out the steps before touching anything, how it decides what even counts as a destructive step worth stopping for, the stuff we built one way and had to tear out and redo, that's a whole post on its own. I'll write that one next, because the planning turned out to be harder and more interesting than the doing.

Making the demo took an afternoon. This is what the months were for.
