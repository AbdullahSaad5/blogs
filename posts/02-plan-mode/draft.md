# The hard part of my AI agent wasn't doing the work, it was planning it

Last post I said the planning turned out harder and more interesting than the doing. This is me paying that off.

Quick recap so this stands on its own. I build a CLI where you type a sentence and an LLM picks one action out of hundreds of apps and runs it on your real accounts. Last post was about direct mode, the get-out-of-my-way mode, and the two things it has to get right every time: which action, and which account. This post is about the other mode. Plan mode. The one that's supposed to be the careful, safe one where the agent shows you what it's going to do before it does it.

I figured plan mode would be the easy half. You don't even execute anything, you just write down the steps. How hard can writing down steps be. It turned out to be most of the months.

## What plan mode is

By default you're in direct mode, and the composer tells you so. There's a little control sitting right there, and if you want to flip to plan mode you click it. That's the whole trigger. The agent never sniffs your request and decides on its own that this one feels risky, because that would be unpredictable and you'd never know which mode you were in. It's your call, every time.

The contract is the one most people already know from other tools. In plan mode the agent makes a plan, you read it, you change what you want or you approve it, and only then does it go and execute. Nothing touches your accounts while you're still looking at the plan. That's the promise. Most of this post is what it took to make that promise actually true, because the first few versions of it were lying to you in one way or another.

## It started inside the main agent, and that was the first mistake

The first version didn't have a planner at all. I had the main agent do both jobs. You'd drop a keyword in your message and that flipped the same agent into planning behavior, it would go research and hand you a plan, and in direct mode that same agent would just do the work. One agent, two modes.

That didn't hold. The two jobs pull in opposite directions. Direct mode wants to act, plan mode wants to hold back and think, and asking one system prompt to be both meant it was good at neither. It would start planning and then drift into doing, or it would be in direct mode and get weirdly cautious. The modes interfered with each other.

So I tore plan mode out of the main agent entirely and made it a separate agent with its own system prompt, written from scratch. This one only researches and produces a plan. It cannot execute anything, that's not a rule I asked it to follow, it's just not wired to. Once planning is its own agent with one job, it stops fighting itself. That was redo number one, and it's the move everything else sits on top of.

## Then it planned for things it had never looked at

The separate planner had a worse problem. It made plans up.

You'd ask for something inside an app, say some work on a Salesforce org, and it would confidently hand back a clean plan. The plan looked great. The plan was fiction. It didn't know what custom objects that org actually had, what fields were already there, what the data looked like, so it filled the gaps with assumptions and wrote those assumptions down as steps. Plans built on guesses break the moment they touch reality.

The fix was to stop letting it plan blind. I gave the planner a set of read-only tools, the non-destructive ones, so before it writes a single step it goes and looks. It reads what's in the org, checks what exists, and plans against what's actually there instead of what it imagined. Research first, plan second. Obvious in hindsight, but the first version genuinely skipped it and just talked.

## Then it researched too little and planned too eagerly

Giving it tools didn't make it use them well. The planner was eager. It wanted to emit a plan, that was the satisfying thing to do, so it would do the bare minimum of looking and rush to the output. It also wouldn't ask you anything, even when it clearly should have, because asking felt like a delay.

I needed it to slow down and ask the right questions before committing to a plan. But there's a trap there. If you make an agent ask questions, it asks bad ones. It asks you things it could have figured out, or things so basic that answering them is annoying, and now the user is doing data entry for the agent. Nobody wants that.

So I didn't cut the questions, I changed their shape. The planner still asks, but every question comes with a recommended answer already filled in, one I supply based on what we already know. So instead of typing out an answer, you're confirming or nudging one. You glance at it, it's usually right, you move on. You only stop and think on the ones that actually need you. That kept the questions, which made the plans real, without turning the user into the planner's research assistant.

## The two agents couldn't talk, so I made the plan carry the conversation

Splitting the planner off solved the interference problem and created a new one. The planner and the main agent are different agents, different sessions, different memories. All the good stuff, the research, the findings, the assumptions, the back-and-forth about what you actually wanted, all of that happened inside the planner. The main agent was never in that room.

So when it came time to execute, I was handing the main agent a list of steps with none of the reasoning behind them. It didn't know why a step was there, what we'd assumed, what we'd ruled out. It was being told what to do with no idea why, which is exactly how you get an executor that does the letter of the plan and misses the point.

The fix was to make the planner's output do double duty. It doesn't just emit steps, it packs the assumptions and the risks and the reasoning into the handoff in a concise form. So the main agent picks up the plan and inherits most of the context that produced it, call it ninety percent of what we worked out together. It knows what it's doing and why, not just the steps.

## What you actually see when you read a plan

Here's where the post 1 promise gets paid. Last time I said plan mode is the answer to the wrong-account problem because you see every step before it runs, including which account it touches. This is that.

The plan is a list of steps in plain English. Where it helps, it gets specific, so for the Salesforce case it names the actual custom objects and fields it's going to touch rather than saying "update some records." Each step tells you what it's going to interact with, and it tells you the blast radius, like how many records or how many people this is going to affect. And critically, each step shows you the alias of the connection it'll run on. Not the raw id, the alias from last post, but enough that you can see this step is going to Client A's org and that one is going to Client B's.

And when you've got more than one connection that fits, the thing that caused the original wrong-org bug, plan mode doesn't guess. It gives you a selectable pick, which connection do you mean, right there in the plan. So the disambiguation that direct mode could only do when the model knew it was unsure now happens up front, in front of you, as a choice you make. That's the gap from post 1, closed. A wrong account shows up as a line you can read before anything runs, not as damage you find afterward.

## Deciding what's destructive, in two layers

A plan is only safe to approve if the dangerous steps are actually marked dangerous, so the agent stops on them. The question is how you know which ones those are.

For our predefined actions it's the nature of the action. Adding, deleting, renaming, that kind of thing gets marked destructive automatically, and when execution reaches a destructive step it stops and asks you before running it. Human in the loop, at the exact step that matters.

The hard case is the raw API fallback from post 1, the escape hatch where there's no predefined action and the agent just makes a direct call. There's nothing to tag there, it's a method and a URL. So two things handle it. First, the agent judges by intent, it knows what the call is actually going to do, and a call gets flagged destructive based on that even when it's a GET that happens to do something dangerous. The verb doesn't decide it, the effect does. Second, under that there's a command classifier that looks at the whole command and rules it safe or not. I ran it across twelve hundred different commands and it sits around ninety-nine percent. So the model's judgment is the smart layer and the classifier is the boring reliable layer beneath it, and a step has to get past both to be treated as harmless.

## The plan isn't a flat list, and it isn't blindly trusted

A couple of things make the plan more than a checklist.

Steps carry criticality. Every step is a must, a should, or a could, and that decides what happens when one fails. A must is the core of the plan, the reason you're here, and if it fails the plan failed, full stop. A should hands the choice to you, the step didn't work, do you want to retry it or move on. A could is something the planner thinks is optional, like backfilling some old records, and if it works great, if it doesn't you just get told and the plan carries on. So a failure halfway through doesn't mean the same thing every time, it means whatever the importance of that step says it means.

Steps also carry evidence. The planner doesn't just research and forget, it attaches the evidence for what it found to the step. So at execution, when it stops to confirm the next step, it shows you the evidence from the one before, and you can actually see what happened rather than trusting that it happened. And if you push back, if you say that step didn't really go through, retry it, it doesn't just blindly redo it. It checks. It can go query the platform and look at the real state, and it'll come back and tell you no, this is already done, you're wrong. It prefers the data over your claim, which is the right call, because the data is the thing that's actually true.

And the plan is a graph, not a line. The planner emits dependencies, this step needs these other steps first, and steps that don't depend on each other can run in parallel while the dependent ones wait their turn. When a destructive step pauses for your confirmation, the whole plan pauses, not just that branch.

That whole picture, the evidence and the criticality and the dependencies, is also why a stale plan isn't a disaster. Research happens at plan time and execution happens later, and the world can move in between. When it does, the agent isn't stuck. It can pause on a step whose evidence no longer matches reality and tell you the thing you approved isn't true anymore. You can cancel a running plan whenever you want. And you can go back to the planner and replan, as many times as you need in the same chat, because the planner keeps its context across the session and can redraw the plan from the new reality. The main agent even gets a say, it can push through an outdated plan by adapting, or it can throw it back and ask for a fresh one. The plan you approved is a starting point, not a contract you're locked into.

## Where it still falls short

Same as last time, I'd rather tell you what this doesn't buy you than let you assume it's airtight.

Prompt injection is still real. The agent reads emails and docs and pages, and if one of those smuggles in an instruction, plan mode doesn't magically stop that. What it does is box it in. The agent has no general execution, it can only act through the defined actions and the connections you authorized, so an injected instruction can't make it do something off the menu, it's stuck inside the same narrow surface as everything else. And in plan mode the whole thing is on the table for you to read before it runs. So injection is bounded, by what the agent is even able to do and by you reviewing it. It is not solved, and I'm not going to pretend it is.

And the planner can still pick the wrong app or the wrong connection. A confidently wrong planner writes a clean, convincing plan for the wrong target, and nothing inside the planner catches that, because it doesn't know it's wrong. The thing that catches it is you, reading the plan, seeing the alias, seeing which org each step is pointed at.

Which is the honest version of the whole post. Both of the gaps that are left, injection and the wrong pick, come down to the human actually reading the plan. Plan mode moves the safety from trust the model to trust the human to look, and that's a real improvement, but it's only worth as much as a user who doesn't just hit approve on reflex. The structural pieces carry their share, the bounded action surface, the alias work from post 1, the classifier under the destructive checks. Review carries the part structure can't reach. If you rubber-stamp the plan, you've handed back the one guarantee plan mode actually gives you.

## What I took from it

Separate the agent that thinks from the agent that acts. The whole thing started working once planning and doing stopped being the same system trying to be two things. One agent that only plans, one that only executes, each good at its one job.

Don't let an agent plan against a world it hasn't looked at. The planner that made things up wasn't dumb, it just had no eyes. Read-only research before it writes a single step did more for plan quality than any amount of prompting the plan to be careful.

If you make an agent ask questions, prefill the answers. Questions make the plan real, but raw questions make the user do the work. A recommended answer they can confirm keeps the rigor and skips the data entry.

Trust verified evidence over the confident claim, including the user's. The step that checks the platform and says "no, this is already done" is more useful than the one that politely redoes whatever you tell it to. Make the data the tiebreaker.

And know exactly what your safety actually rests on. Plan mode's structural guarantees are narrow and real. Everything past them rests on a person reading the plan. That's fine, as long as you're honest that it's true, and you don't build the rest of the system pretending the human is a backstop that never blinks.

The doing took an afternoon. The planning is what the rest of the months were for, and I think it's the more interesting half.
