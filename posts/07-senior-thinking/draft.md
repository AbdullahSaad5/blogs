<!--
TITLE LOCKED 2026-08-03: "How to Think Like a Senior Developer" (chosen from 5 options; safe/searchable register).

FACTUAL PASS COMPLETE 2026-08-03 (all 5 confirmed by Saad; draft updated accordingly):
1. Browser memory figure: confirmed as written.
2. Browser optimizations: SHIPPED (Saad corrected 2026-08-03; earlier "built and tested locally" was wrong) - draft says "That shipped".
3. Stripe fix order: payment intent first, ID saved to DB, then charge; webhook matches later. Draft rewritten.
4. Stripe retries: handler returns 200 (no Stripe retry), webhook saved as pending, cron matches 3-4 more times, stays pending for admin review, logged. Draft rewritten.
5. Two per-user services: confirmed.

VOICE REWRITE 2026-08-03: full pass into house register (contractions, first-person scenes, so-chained flow) per Saad's "looks and sounds different" flag. Facts unchanged.
POINT-FIRST RESTRUCTURE 2026-08-03: per Saad "give points and tell stories along the way" - each section now leads with the habit (what a senior does), the story shows the consequence (what happens if you don't), the lesson lands at the end. Facts unchanged.
FACT CORRECTION 2026-08-03: the wrong assumption was "listing shows out of stock", NOT "listing disappears" (Saad). Line fixed.
SIX-HABIT EXPANSION 2026-08-03: added habits 6-11 (plan/classify destructive steps, know who you're acting for, enumerate unseen cases, audit as an outsider, verify the real output, blast-radius design) per Saad "list them down we need to add those as well". Stories grounded in published posts 01-05 + the Shajrah audit. Lede + recap updated to eleven parts. NOTE: clarify option said "ten" - actual count is eleven (miscount on my side).
CONCISION PASS 2026-08-03: per Saad "make it concise" - every section compressed to point -> story -> one-line lesson; doubled paragraphs merged; opening tightened; all 11 habits and all verified facts kept.
-->

# How to Think Like a Senior Developer

Thinking like a senior developer is a habit, and I've learned it the hard way. Here's the habit in eleven parts, and the stories behind them.

We were building an e-commerce portal where a seller enters a product once and publishes it to their own website, eBay, Amazon, or all three. We made one form for everything, and one click created the catalog entry, added the stock, and published the listings.

We assumed the client wanted to sell exactly what they entered, and when the stock ran out, the listing would show out of stock.

Nobody asked whether the product, the stock, and the listing shared one lifecycle. We found out at the client demo that they did not.

The client wanted the catalog entry to exist once, with every shipment adding stock against it. Listings were separate: ten listings against one batch of stock, and a depleted batch didn't kill a listing, because the business accepted order leads and sourced another unit after an order arrived.

The form worked. It worked according to a business model the client never wanted. By then the assumption was in the database, the API, the inventory workflow, the form, and the listing logic. We rebuilt it. Assumptions become architecture fast, and once a client sees the wrong one in a demo, it's expensive to remove.

## Ask the question before the code answers it

The first habit: ask the question before the code answers it.

I've made this mistake too, so I don't see senior thinking as a title you earn and then stop worrying. It's a habit of slowing down when the team is about to turn an assumption into code.

Some of the useful questions sound dumb:

- Can one product have several batches of stock?
- Can several listings point to the same stock?
- What happens to a listing when stock reaches zero?
- Does an order fail, or does it become a lead for stock we can source?

Those four questions would have changed our database model before we built the form. Nobody asked them, so the wrong model shipped, and the demo is where we found out. That's the price of skipping this habit.

The second half of the habit is writing the answers down: the requirement, the assumptions we confirmed, the risks we found, the options we rejected, and why we picked the final approach. Someone can come back later and understand the decision without rebuilding the whole conversation. The code keeps the decision long after the conversation is forgotten.

## When the scope multiplies, revisit the unit of work

The second habit: when the scope multiplies, revisit the unit of work.

The same project handed me the same lesson a second time. Seven product categories across the website, eBay, and Amazon, each wanting different fields. Our first plan was to hard-code the forms. For seven categories, that looked fine. Then the client said 43.

The first response was to estimate the time for 36 more hand-built categories. That's the junior move, and I don't mean junior as an insult. When the quantity jumps, the instinct is to recalculate the same plan.

I looked at the repetition and asked why we were doing this by hand at all. The marketplace schemas already described their own fields.

So we pulled those schemas at runtime, matched the fields in code, and generated the form from what the user selected. 43 categories worked, and if the client had asked for another hundred, we had a path that didn't involve another category-by-category project.

The jump exposed the real unit of work: the category needed to become data the system could interpret. When a request multiplies, don't just recalculate the estimate. Repetition in the plan is the sign that the real task is to build the mechanism.

## Multiply the design before calling it done

The third habit: multiply the design before calling it done.

A colleague built a feature where each user's AI agent controlled a browser while the user watched from the UI and could take over. It worked. Then I multiplied the design by the user count: two services per user, and at 300 to 400 MB per user, thousands of users is hundreds of gigabytes of memory.

The UI only needed to show the page the agent was on and let the user take over. Streaming the whole browser carried developer tools, settings, and everything else the user would never touch.

So we built a smaller custom UI, lighter communication with the front end, and the browser service starting on demand and shutting down after an idle period. That shipped, and it kept the smooth takeover experience while giving the system a much better path to scale.

"The feature works" only proves the single-user path. The senior move is to change the multiplier and ask what grows once per user.

## Trace the whole workflow

The fourth habit: when something breaks, trace the whole workflow before touching anything.

A product owner once told me a user had paid for a background check that never ran, and their status never changed. They couldn't continue. Stripe showed the payment. The easy assumption was that the background-check API had changed, or that our request to it failed.

I traced the workflow backward instead. We charged the user's saved payment method, wrote the payment intent ID to MongoDB, then handled Stripe's webhook. The webhook used that ID to find the user and start the check.

Sometimes Stripe delivered the webhook before MongoDB finished the write. The handler looked for the ID, found nothing, discarded the event, and the user stayed stuck.

The complaint was accurate but incomplete. The visible failure was "I paid and nothing happened." Underneath, the real problem was the timing assumption. The reported symptom wasn't the cause.

The fix had two layers. The payment intent comes first, so its ID already exists. We save it to the database, then charge. The webhook always has a record to match.

And I stopped depending on one perfectly timed delivery: the handler returns 200 so Stripe doesn't retry, and the webhook is saved as pending. A cron tries to match it three or four more times, and if it still finds nothing, it stays pending for an admin to review, logged in case we need it later.

I use the same idea for regression checks. Find every place that calls the code you're changing, then trace the workflows around those callers. A local fix can change behavior somewhere else in the system.

## Put the risks inside the plan

The fifth habit: put the risks inside the plan.

That rebuild I described at the top is why. We built the wrong model for a long time, and now I never commit to the best-case number as the delivery date.

The clean path always gives you a best-case number: the API behaves, the existing code has no surprises, the test data is ready, every assumption holds. That number is the floor of a good estimate, not the estimate.

A useful estimate carries its risks: what we still need to verify, which dependencies are outside our control, which parts need regression testing. And which assumptions the number depends on, so when one of them changes, the client can see why the plan changes with it.

This is another reason documentation matters. It keeps the estimate tied to what we knew when we made it.

## Plan before you execute

The sixth habit: plan before you execute. Most of the time belongs in the planning.

That's where you expand the domain of everything. Go down every branch and decide what should happen on each one. Walk the alternative flows for everything that can go right, then look at what can go wrong and how you'd come back from it.

The e-commerce project is the same lesson from the other side. The questions we didn't ask, the plan we didn't make, the alternative flows we never walked. The plan was the product, and we rushed past it to the code.

If I had an hour to solve a problem, I'd spend 55 minutes thinking about the problem and 5 minutes thinking about solutions. A senior plan also knows which steps can't be undone, and treats the irreversible ones like they cost something.

## Know who you're acting for

The seventh habit: know who you're acting for. Get into the head of the person who's going to use what you build.

How will they look at the system? How will they understand it? How do your words affect them, every label, every error message, every confirmation? How does the workflow run for them, not for you? And what's the easiest way to make it dumb-proof, so a user can't accidentally do much damage?

We built the e-commerce form the way we would use it, and the client operated differently. That's the gap this habit closes.

The user is the actor the system works for. If you don't know how they think, you're building for yourself.

## List the cases nobody raised

The eighth habit: list the cases nobody raised.

I built a billing system with AI doing most of the work. It was fast, and it handled everything we told it about. It never handled what we didn't: buying a second package mid-cycle, or what happens to existing subscribers when an admin changes a plan.

Charge the difference now or next cycle? Migrate everyone or grandfather them? Those questions never came up, because nothing in the request mentioned them. The model didn't see the case at all. Someone had to enumerate it.

Existing users, mid-cycle changes, migrations. The code handles what you tell it. The list of what you didn't tell it is yours to make. Those gaps surface at a demo, or after launch.

## Audit it the way an outsider sees it

The ninth habit: audit your system the way an outsider sees it.

I found a moderation flaw in my own family-tree project by using the API the way a stranger would, instead of reading the code. From the inside, the workflow looked right: submissions went to pending, moderators approved them.

Then I tried it as an anonymous caller. One query parameter later I was reading the pending queue directly. Blocking an account did nothing for fifteen minutes, because the middleware never checked the account status.

The features were decorative. They looked right to the people who built them, and did nothing for the people they were supposed to protect. If you only look at the system the way you built it, you'll never see what it looks like to someone it was built against.

## Verify the real output, not the signal

The tenth habit: verify the real output, not the signal that it ran.

I built a wrapper so my agent could write documents without a five-thousand-token script. By every signal it worked. The agent produced files, fast. Then I looked at what it actually made.

Every document had the same shape, generic structure, generic wording, the same deck no matter what it was for. One slide overflowed its table and just said "(cont.)".

The agent declared victory the moment the file existed. The file was the exit ramp: the work looked done the second a thing existed, and the thing was generic. A passing build isn't a working feature. Look at what came out before you call it done.

## Make failure cost as little as possible

The eleventh habit: design so a failure costs as little as possible.

The agent system had to reach three third-party services, each with its own key shape and scope. The prototype put the real keys where the agent could reach them. It worked, and then it showed me exactly why it was wrong: the only thing stopping the agent from using a key wrongly was a sentence in a prompt.

So the design changed. The agent never holds a real credential. It holds our own stand-in key, and the middleware swaps it for the real one underneath on every call. Killing the stand-in kills that agent's access on the next call, while the real keys keep working.

Enforcement lives below the model, where it can't be argued with.

## The problem is bigger than the ticket

So what does a senior do differently?

- They ask the question before the code answers it.
- When the scope multiplies, they revisit the unit of work.
- They multiply the design by the user count.
- They trace the whole workflow.
- They put the risks inside the plan.
- They plan before executing, and classify the steps that can't be undone.
- They know who they're acting for.
- They list the cases nobody raised.
- They audit the system the way an outsider sees it.
- They verify the real output, not the signal.
- They design so a failure costs as little as possible.

The more systems I work on, the more I ask before changing one. What happens when seven becomes 43, or one user becomes thousands?

Years of experience help because they give you more failures to remember. The useful part is the habit of looking past the code directly in front of you. That wider view is what I mean when I say someone thinks like a senior developer.
