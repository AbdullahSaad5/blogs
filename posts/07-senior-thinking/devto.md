---
title: How to Think Like a Senior Developer
published: false
description: We built one form for the catalog, the stock, and the listings, and nobody asked whether they shared a lifecycle. The client demo proved us wrong. Senior thinking is the habit of catching assumptions before they become architecture.
tags: programming, career, softwareengineering, productivity
cover_image:
canonical_url:
---

We were building an e-commerce portal where a seller enters a product once and publishes it to their own website, eBay, Amazon, or all three.

We made one form for everything. Product information, images, inventory, listing details, all in one submission. One click created the catalog entry, added the stock, and published the listings.

It made sense to us. We assumed the client wanted to sell exactly what they entered, and when the stock ran out, the listings should disappear.

Nobody asked whether the product, the stock, and the listing shared one lifecycle.

We found out at the client demo that they did not.

The client wanted the catalog entry to exist once, with every new shipment adding another batch of stock against it, without re-entering the images or the product information.

Listings were separate too. Ten listings against one batch of stock, more listings later, and a depleted batch did not kill a listing, because the business accepted order leads and sourced another unit after an order arrived.

The form worked. It worked according to a business model the client never wanted.

By then the assumption was in the database, the API, the inventory workflow, the form, and the listing logic. We rebuilt it. Assumptions become architecture fast, and once a client sees the wrong one in a demo, it's expensive to remove.

## Ask the question before the code answers it

I've made this mistake too, so I don't see senior thinking as a title you earn and then stop worrying. It's a habit of slowing down when the team is about to turn an assumption into code.

Some of the useful questions sound dumb:

- Can one product have several batches of stock?
- Can several listings point to the same stock?
- What happens to a listing when stock reaches zero?
- Does an order fail, or does it become a lead for stock we can source?

Those four questions would have changed our database model before we built the form.

I also write the answers down. The requirement, the assumptions we confirmed, the risks we found, the options we rejected, and why we picked the final approach.

The point of documentation is that someone can come back later and understand the decision without rebuilding the whole conversation. The code keeps the decision long after the conversation is forgotten.

## When seven categories became 43

The same project handed me the same lesson a second time. The original scope was seven product categories across the website, eBay, and Amazon. Each marketplace wanted different fields, so our first plan was to pull the schemas, merge the mandatory and optional fields, and hard-code the resulting forms.

For seven categories, that looked fine. Then the client said 43.

The first response was to estimate the time for 36 more hand-built categories. I looked at the repetition and asked why we were doing this by hand at all. The marketplace schemas already described their own fields. So we changed the system to pull those schemas at runtime, match the fields in code, and generate the form from what the user selected.

43 categories worked after that. If the client had asked for another hundred, we had a path that did not involve another category-by-category project.

The jump from seven to 43 exposed the real unit of work. The category needed to become data the system could interpret. When a request multiplies, don't just recalculate the estimate. Repetition in the plan is often the sign that the real task is to build the mechanism.

## Multiply the design before calling it done

Another project, each user had their own environment running their AI agent, and we wanted the agent to control a browser while the user watched from the UI and could take over. A colleague built it and it worked. The agent drove the browser, its actions showed up in the UI, and the user could grab control.

Then I multiplied the design by the user count. The implementation added two services per user. Even at 300 to 400 MB per user, thousands of users is hundreds of gigabytes of memory.

The UI only needed to show the page the agent was on and let the user take over. Streaming the whole browser carried developer tools, settings, and everything else the user would never touch.

So we built a smaller custom UI, lighter communication with the front end, and the browser service starting on demand and shutting down after an idle period. We built and tested that locally, and it kept the smooth takeover experience while giving the system a much better path to scale.

"The feature works" only proves the single-user path. The senior move is to change the multiplier and ask what grows once per user.

## Trace the whole workflow

A product owner once told me a user had paid for a background check and the check never ran. Their status never changed, so they couldn't continue to the service.

Stripe showed the payment. The easy assumption was that the background-check API had changed, or that our request to it failed.

I traced the workflow backward instead. We charged the user's saved payment method, wrote the payment intent ID to MongoDB, and then handled Stripe's webhook. The webhook used that ID to find the user and start the check.

Sometimes Stripe delivered the webhook before MongoDB finished the write. The handler looked for the ID, found nothing, discarded the event, and the user stayed stuck.

The complaint was accurate but incomplete. The visible failure was "I paid and nothing happened." The real failure was the timing assumption underneath.

I reordered it. The payment intent comes first, so its ID already exists. We save it to the database, then charge. The webhook always has a record to match.

And I stopped depending on one perfectly timed delivery. The handler returns 200 so Stripe doesn't retry the event, and saves the webhook to the database as pending. A cron job tries to match it three or four more times. If it still finds nothing, the event stays pending for an admin to review, and it is logged in case we need it later.

I use the same idea for regression checks. Find every place that calls the code you're changing, then trace the workflows around those callers. A local fix can change behavior somewhere else in the system. You have to follow the call far enough to see who else depends on it and what state they expect.

## Put the risks inside the plan

Thinking past the immediate task also changes how I estimate. The clean path gives you a best-case number: the API behaves, the existing code has no surprises, the test data is ready, every assumption holds. I never commit to that number as the delivery date.

A useful estimate carries its risks. What we still need to verify, which dependencies are outside our control, which parts of the system need regression testing. And which assumptions the number depends on, so when one of them changes, the client can see why the plan changes with it.

This is another reason documentation matters. It keeps the estimate tied to what we knew when we made it.

## The problem is bigger than the ticket

The more systems I work on, the more questions I ask before changing one. Is the reported problem the cause, or the last symptom in a longer workflow? Which callers depend on this code? What state do they expect? What happens when seven becomes 43, or one user becomes thousands?

Years of experience help because they give you more failures to remember. The useful part is the habit of looking past the code directly in front of you.

That wider view is what I mean when I say someone thinks like a senior developer.
