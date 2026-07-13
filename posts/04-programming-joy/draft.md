<!--
DRAFT — needs Saad's voice pass before publishing (feedback-log rule: no autopilot publish).
Opinion essay. Stance = (c) traded: gains real, the joy diminished not dead, the real loss is
ownership + appreciation for craft. Ending softened, appreciation aimed wide (craft as a value),
not personal credit. Zero em-dashes by rule.

TITLE (2026-06-27): "I'm shipping the best work of my career. None of it feels like mine."
Dropped two earlier tries: the "I build AI agents for a living" vantage (Saad: spammy, and it wrongly
implied his built agent took his joy vs the AI he codes with) and a chair-jump title (Saad: chair
imagery not good in a title). Final lands on the ownership thesis, the real center of the piece.
-->

# I'm shipping the best work of my career. None of it feels like mine.

A few years back I was a junior dev on a car financing product, and I got handed the deal jacket.

A deal jacket is the full picture of a deal. How much the buyer puts down, what the car is worth, the terms, all of it packaged up and sent to a bank so the bank can come back with a yes or a no. The flow I had to build would send that package to one bank, wait about a minute for an answer, check whether the offer that came back was any good, and if it wasn't, send the whole thing to the next bank. A pipeline. Under the hood it was a recursive call with state managed in between, talking to Route One on the other side.

It kept breaking. I wrote it, tested it, read the logs, fixed one thing, watched it break somewhere else. Day three, day four, still broken. Then on the fourth day I hit send in Postman one more time, watched the logs roll past, and it just worked. The approval came back clean. I jumped out of my chair. I was loud enough that the whole room looked over, and the two guys who knew what I'd been stuck on for four days were already grinning, because they knew exactly what had just happened.

That feeling is the whole reason I'm writing this. Not the code. The feeling.

## The joy had two parts, and I only saw the second one once it was gone

The first part is obvious. It's the problem solving. The thing fought back for four days and then it didn't, and I had beaten it. You chase a bug through the logs, you argue with it, and at some point it gives. That is a real high and every engineer knows it.

The second part is quieter. I built that. Me. Back then if I shipped something, even a plain HTML page, it was mine end to end. I had to learn HTML before I could build the page, so the page was proof that I had learned. You could point at the thing and say that came out of my head and my hands, and nobody could take that from you.

So the joy was solving the problem, and it was owning what you solved. That second part is the one that broke.

## Same problem, four years apart

Take payment gateways. When I was junior I tried to wire up Stripe and I got it wrong, the way juniors get it wrong. I trusted the client. The browser said the payment went through, so I believed it. I didn't know you are supposed to wait for the webhook to come back to your server and actually confirm what happened. Payment complete, payment failed, a 3D Secure step in the middle, a declined card, something flagged as fraud. I learned all of that the slow way, across a few projects. Race conditions. Duplicate webhooks. Stale webhooks. By the end I could say, honestly, that a payment gateway is hard, and I knew why it was hard, because I had been burned by every one of those cases.

Last month I built another billing system. This one was nastier on paper. Not a simple subscription where you pay and unlock a tier, but a setup where an admin builds packages by hand: token spend limits, how many connections, how many records, how many sessions, seven or eight modules and each one with ten-plus things you have to capture to define a single plan. It had to talk to QuickBooks and a drive and everything in between.

The AI shipped it with me in under a week. Hardened the parts I would have missed, found cases I didn't know to look for, walked me through how one piece talked to the next. I brought my experience to it, I wasn't asleep at the wheel. But I watched it have an answer for everything, and I watched it catch the things that, four years ago, would have been my four-day fight.

And then there was the case it never even raised. What happens when someone buys a second package halfway through a billing cycle. What happens when an admin changes a plan and there are already people sitting on the old one. The model built exactly the plan I described and never thought to ask what that plan does to the people already inside it. Catching those wasn't the hard part. The hard part was deciding what should happen. Charge the difference today or roll it into next cycle. Move everyone onto the new plan, or let them keep what they signed up for. None of that is a technical question. It comes down to what feels fair and what people will forgive, and the model has no read on either. I made those calls, and they were the only part of the whole week that felt like mine.

It had more moving parts than the deal jacket ever did. The PR merged, the checks went green, I closed the laptop. No chair. Nobody looked over. I felt almost nothing.

## What we actually do now

The shape of the work changed. The hard problem used to land on your desk and stay there until you cracked it. Now you mostly describe it, review what comes back, find what it missed, delete, and ship. It's faster. It's also a different job.

I've seen teams wire it all the way through. An error throws in production, the stack trace posts itself into a Slack channel, the agent is sitting in that same channel, so someone tags it. It reads the trace, opens a PR, and asks you to review. You review, you merge, the problem is gone. Nobody ever held the problem. It came in and left and no human really touched the middle of it.

And here is the thing I miss most, which has nothing to do with code. I miss the people part of solving things. Teasing a coworker because the bug that wrecked his afternoon took you one glance to spot. Being the rubber duck, where someone explains the problem to you out loud and stops halfway through because the answer hit him mid-sentence and he's already walking back to his laptop. The pressure of a client saying prod is down, the whole team staring at a wall of logs, nobody knowing yet, venting at each other and laughing about it later. You talk to the model now. It fixes things, you check them, and the exchange is fine, but the teasing and the adrenaline and the click of explaining it to another human, that part is just gone.

## The real loss is ownership

Missing the grind is the easy version of this. The harder part is about ownership.

When everyone can build, building stops meaning anything. That sounds harsh but watch how it plays out. People who never learned to code now open a tool, try things, and ship something real. Good for them, genuinely. But the side effect is that if I build the next Facebook tomorrow, the reaction isn't "how did you do that," it's "oh, you used AI." The credit goes to the tool. The work gets waved off. The person who didn't really do it takes the bow, and the person who did gets told it was easy.

On the front end it's even starker, because the client only ever sees the surface. They don't see the architecture or the edge cases or the years that taught you which corners you can cut and which ones break things later. They see the look and the feel. And a junior with the best model can put up a better looking app than a senior with a weaker one. Not better underneath. Better looking. From where the client sits, that's the whole game.

So the craft flattens into a question of who has the better tool. The taste you spent years building, the judgment, the part of you that knew why one layout breathes and another one doesn't, a script with a strong model can fake the result well enough that nobody checks. The market is flooded with things that look good, and the difference between earned and generated stopped being something most people can see at a glance. When nobody can see the difference, nobody values it either. That is the loss, and it isn't about my credit. It's that good work, anyone's good work, stops being something worth recognizing at all.

## I'm not going to pretend the trade was bad

Because it wasn't, and I'd be lying if I sold you the sad version straight.

We used to talk about the 10x engineer, the one person who could do the work of ten, the one who seemed to know everything, the one everyone walked over to when they were stuck. Everyone wanted to be that. AI quietly moved the ceiling. The same person is now closer to 100x, and a lot of the hours that used to vanish into nothing are just gone in a good way.

Think about building a dashboard before. You'd lose two or three weeks just standing the thing up. Sidebar that collapses and expands without jumping, tables that don't fall apart, filtering that actually filters. The mediocre scaffolding. Only after all that did you get to the part that separates you from an average front-end dev, the animation, the polish, the small touches that make it feel expensive. AI does the scaffolding now, from the first hour, so you spend your good time on the part that was always the point.

It cuts both ways. The same democratization that diluted the craft is also the best thing AI did. People with a real idea and no CS degree finally get to make it. Tools exist now that simply wouldn't have, because the person who needed them couldn't have built them before and can today. There's an old joke about spending ninety hours automating a task to avoid one hour of doing it. Those ninety hours are gone. You automate it in one, it's done for good, and half the time you open-source it and someone else's afternoon gets easier too.

It's a better teacher than most seniors I've had, too. All that payment-gateway knowledge that cost me a few projects to absorb, a junior gets on day one now, because the AI explains while it builds. And it killed the toil nobody ever loved, the config, the migrations, the glue code, the two in the morning fighting a build that won't go green. Not everything it took from us was joy. A lot of it was just pain.

So no, the joy isn't dead.

## Where it actually leaves me

The scoreboard is broken. The public one, the one where you build something good and the world looks at it and knows it's good. That one isn't coming back, and most days I think we shipped it off in exchange for speed and reach and a lot of people getting to build who never could before. On balance that might even be a fair trade.

But the joy didn't disappear. It went private. It stopped being something the room handed you when you jumped out of your chair, and turned into something you have to choose. The satisfaction of the part that was actually yours, the call the model couldn't make for you, the thing you decided and still own, that's still there. Nobody is going to clap for it. They can't tell it apart from the generated version anyway. So it's yours now in a way it wasn't before, for exactly the reason that it stings: because you're the only one who'll know.

I still chase that. I just had to get used to chasing it quietly.
