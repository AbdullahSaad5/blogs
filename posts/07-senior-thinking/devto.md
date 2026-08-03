---
title: How to Think Like a Senior Developer
published: false
description: We built one form for the catalog, the stock, and the listings, and nobody asked whether they shared a lifecycle. The client demo proved us wrong. Senior thinking is the habit of catching assumptions before they become architecture.
tags: programming, career, softwareengineering, productivity
cover_image:
canonical_url:
---

Thinking like a senior developer is a habit, and I've learned it the hard way. Here's the habit in eleven parts, and the story behind each one.

We were building an e-commerce portal where a seller enters a product once and publishes it to their own website, eBay, Amazon, or all three.

We made one form for everything. Product information, images, inventory, listing details, all in one submission. One click created the catalog entry, added the stock, and published the listings.

It made sense to us. We assumed the client wanted to sell exactly what they entered, and when the stock ran out, the listing would show out of stock.

Nobody asked whether the product, the stock, and the listing shared one lifecycle.

We found out at the client demo that they did not.

The client wanted the catalog entry to exist once, with every new shipment adding another batch of stock against it, without re-entering the images or the product information.

Listings were separate too. Ten listings against one batch of stock, more listings later, and a depleted batch did not kill a listing, because the business accepted order leads and sourced another unit after an order arrived.

The form worked. It worked according to a business model the client never wanted.

By then the assumption was in the database, the API, the inventory workflow, the form, and the listing logic. We rebuilt it. Assumptions become architecture fast, and once a client sees the wrong one in a demo, it's expensive to remove.

## Ask the question before the code answers it

The first habit: ask the question before the code answers it.

I've made this mistake too, so I don't see senior thinking as a title you earn and then stop worrying. It's a habit of slowing down when the team is about to turn an assumption into code.

Some of the useful questions sound dumb:

- Can one product have several batches of stock?
- Can several listings point to the same stock?
- What happens to a listing when stock reaches zero?
- Does an order fail, or does it become a lead for stock we can source?

Those four questions would have changed our database model before we built the form. Nobody asked them, so the wrong model shipped, and the demo is where we found out. That's the price of skipping this habit.

The second half of the habit is writing the answers down. The requirement, the assumptions we confirmed, the risks we found, the options we rejected, and why we picked the final approach.

The point of documentation is that someone can come back later and understand the decision without rebuilding the whole conversation. The code keeps the decision long after the conversation is forgotten.

## When seven categories became 43

The second habit: when the scope multiplies, revisit the unit of work.

The same project handed me the same lesson a second time. The original scope was seven product categories across the website, eBay, and Amazon. Each marketplace wanted different fields, so our first plan was to pull the schemas, merge the mandatory and optional fields, and hard-code the resulting forms.

For seven categories, that looked fine. Then the client said 43.

The first response was to estimate the time for 36 more hand-built categories. That's the junior move, and I don't mean junior as an insult. When the quantity jumps, the instinct is to recalculate the same plan. I looked at the repetition and asked why we were doing this by hand at all. The marketplace schemas already described their own fields.

So we changed the system to pull those schemas at runtime, match the fields in code, and generate the form from what the user selected.

43 categories worked after that. If the client had asked for another hundred, we had a path that did not involve another category-by-category project.

The jump from seven to 43 exposed the real unit of work. The category needed to become data the system could interpret. When a request multiplies, don't just recalculate the estimate. Repetition in the plan is the sign that the real task is to build the mechanism.

## Multiply the design before calling it done

The third habit: multiply the design before calling it done.

Another project, each user had their own environment running their AI agent, and we wanted the agent to control a browser while the user watched from the UI and could take over. A colleague built it and it worked. The agent drove the browser, its actions showed up in the UI, and the user could grab control.

Then I multiplied the design by the user count. The implementation added two services per user. Even at 300 to 400 MB per user, thousands of users is hundreds of gigabytes of memory.

The UI only needed to show the page the agent was on and let the user take over. Streaming the whole browser carried developer tools, settings, and everything else the user would never touch.

So we built a smaller custom UI, lighter communication with the front end, and the browser service starting on demand and shutting down after an idle period. That shipped, and it kept the smooth takeover experience while giving the system a much better path to scale.

"The feature works" only proves the single-user path. The senior move is to change the multiplier and ask what grows once per user. If the answer is memory, or a service, or a process, that growth belongs in the design before the feature is called finished.

## Trace the whole workflow

The fourth habit: when something breaks, trace the whole workflow before touching anything.

A product owner once told me a user had paid for a background check and the check never ran. Their status never changed, so they couldn't continue to the service.

Stripe showed the payment. The easy assumption was that the background-check API had changed, or that our request to it failed.

I traced the workflow backward instead. We charged the user's saved payment method, wrote the payment intent ID to MongoDB, and then handled Stripe's webhook. The webhook used that ID to find the user and start the check.

Sometimes Stripe delivered the webhook before MongoDB finished the write. The handler looked for the ID, found nothing, discarded the event, and the user stayed stuck.

The complaint was accurate but incomplete. The visible failure was "I paid and nothing happened." The real failure was the timing assumption underneath. The reported problem was the last symptom, not the cause.

The fix had two layers. I reordered the workflow so the payment intent comes first, its ID gets saved to the database, and only then do we charge. The webhook always has a record to match.

And I stopped depending on one perfectly timed delivery. The handler returns 200 so Stripe doesn't retry the event, and saves the webhook to the database as pending. A cron job tries to match it three or four more times. If it still finds nothing, the event stays pending for an admin to review, and it is logged in case we need it later.

I use the same idea for regression checks. Find every place that calls the code you're changing, then trace the workflows around those callers. A local fix can change behavior somewhere else in the system. You have to follow the call far enough to see who else depends on it and what state they expect.

## Put the risks inside the plan

The fifth habit: put the risks inside the plan.

That rebuild I described at the top is why. We built the wrong model for a long time, and now I never commit to the best-case number as the delivery date.

The clean path always gives you a best-case number: the API behaves, the existing code has no surprises, the test data is ready, every assumption holds. That number is the floor of a good estimate, not the estimate.

A useful estimate carries its risks. What we still need to verify, which dependencies are outside our control, which parts of the system need regression testing. And which assumptions the number depends on, so when one of them changes, the client can see why the plan changes with it.

This is another reason documentation matters. It keeps the estimate tied to what we knew when we made it.

## Plan before you execute

The sixth habit: plan before you execute, and know which steps can't be undone.

I built an agent that was supposed to do real work, and the planning turned out to be the hard part. The first version planned and executed in the same pass, and it was too eager. It planned blind, then it jumped.

So we split it: a separate planner that investigated and proposed steps, and an executor that ran the approved ones. Every step carried a criticality, must, should, or could.

Destructive steps got classified before they could run, two layers deep, one reading the intent and one reading the raw command. The classifier caught roughly 99% of destructive commands across the 1,200-command action space, and the misses were the ones that mattered, because a destructive command waved through is the expensive kind of miss.

The planning was harder than the doing. That's the point. A senior plan knows which steps are reversible and which aren't, and treats the irreversible ones like they cost something.

## Know who you're acting for

The seventh habit: know who you're acting for.

My agent once wrote to the wrong client's Salesforce. It was doing real work in a real account, and nothing pinned down which client it was acting for. The context lived in the conversation, and the conversation was wrong.

We fixed it by making the tenant part of the runtime, not the prompt: the agent carries which client it's acting for, and it stops when it's unsure.

Before any change, ask who this is for. Which client, which tenant, which account. The prompt can't be trusted to remember. The platform has to know.

## List the cases nobody raised

The eighth habit: list the cases nobody raised.

I built a billing system with AI doing most of the work. It was fast, and it handled everything we told it about. It never handled what we didn't: buying a second package in the middle of a billing cycle, or what happens to existing subscribers when an admin changes a plan.

Charge the difference now or next cycle? Migrate everyone or grandfather them? Those questions never came up, because nothing in the request mentioned them. The model didn't see the case at all. Someone had to enumerate it.

Existing users, mid-cycle changes, migrations. The code handles what you tell it. The list of what you didn't tell it is yours to make.

## Audit it the way an outsider sees it

The ninth habit: audit your system the way an outsider sees it.

I found a moderation flaw in my own family-tree project by using the API the way a stranger would, instead of reading the code. From the inside, the workflow looked right: submissions went to pending, moderators approved them.

Then I tried it as an anonymous caller. One query parameter later I was reading the pending queue directly. Blocking an account did nothing for fifteen minutes, because the middleware never checked the account status.

The features were decorative. They looked right to the people who built them, and did nothing for the people they were supposed to protect.

The senior habit is stepping outside your own view of the system. If you only look at it the way you built it, you'll never see what it looks like to someone it was built against.

## Verify the real output, not the signal

The tenth habit: verify the real output, not the signal that it ran.

I built a wrapper so my agent could write documents without a five-thousand-token script. By every signal it worked. The agent produced files, fast. Then I looked at what it actually made.

Every document had the same shape. Generic structure, generic wording, the same deck no matter what it was for. One slide overflowed its table and just said "(cont.)".

The agent declared victory the moment the file existed. The file was the exit ramp: the work looked done because a thing existed, not because the thing was right.

A passing build isn't a working feature. The artifact is what counts, so look at what came out before you call it done.

## Make failure cost as little as possible

The eleventh habit: design so a failure costs as little as possible.

The agent system had to reach three third-party services, and each one had its own key shape and scope. The prototype put the real keys where the agent could reach them. It worked, and then it showed me exactly why it was wrong: the only thing stopping the agent from using a key wrongly was a sentence in a prompt.

So the design changed. The agent never holds a real credential. It holds our own stand-in key, and the middleware swaps it for the real one underneath on every call. Killing the stand-in kills that agent's access on the next call, while the real keys keep working.

Enforcement lives below the model, where it can't be argued with. You build so that when the system is wrong, it costs as little as possible.

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

The more systems I work on, the more I ask before changing one. Is the reported problem the cause, or the last symptom in a longer workflow? Which callers depend on this code? What state do they expect? What happens when seven becomes 43, or one user becomes thousands?

Years of experience help because they give you more failures to remember. The useful part is the habit of looking past the code directly in front of you.

That wider view is what I mean when I say someone thinks like a senior developer.
