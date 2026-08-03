---
title: How to Think Like a Senior Developer
published: false
description: We built one form for the catalog, the stock, and the listings, and nobody asked whether they shared a lifecycle. The client demo proved us wrong. Senior thinking is the habit of catching assumptions before they become architecture.
tags: programming, career, softwareengineering, productivity
cover_image:
canonical_url:
---

We were building an e-commerce portal that let a seller enter a product once and publish it to their website, eBay, Amazon, or all three.

We made one form for everything. The seller added the product information, images, inventory, and listing details. One submission created the catalog entry, added its stock, and published the listings.

That workflow made sense to us. We assumed the client wanted to sell exactly what they entered, and when that stock ran out, its listings should disappear.

Nobody asked whether the product, the stock, and the listing actually had the same lifecycle.

We got to the client demo before we learned that they did not.

The client wanted to create a product catalog separately and reuse it. Every new shipment would add another batch of stock against that product without making someone enter the images and product information again.

Listings were separate too. They might create ten listings against one batch of stock, then create more listings later without rebuilding the catalog.

Even when the current stock ran out, the listing could stay live. The business accepted order leads, so they could source another unit after an order arrived.

The form worked according to a business model the client never wanted.

That assumption had already spread into the database, the API, the inventory workflow, the form, and the listing logic. We had spent a long time building it, and now we had to do it again.

Assumptions become architecture very quickly. By the time a client sees the wrong one in a demo, it can be expensive to remove.

## Ask the question before the code answers it

I made that mistake too, so I do not see senior thinking as a title that makes someone immune to bad decisions. It is a habit of slowing down when the team is about to turn an assumption into code.

Some of the useful questions sound dumb:

- Can one product have several batches of stock?
- Can several listings point to the same stock?
- What happens to a listing when stock reaches zero?
- Does an order fail, or does it become a lead for stock we can source?

Those questions would have changed our database model before we built the form.

I also document the answers. I record the requirement, the assumptions we confirmed, the risks we found, the options we rejected, and why we chose the final approach.

Useful documentation preserves the context around a decision. Someone should be able to understand it later without rebuilding the entire conversation or reading an explanation of every line.

The code keeps the decision long after the conversation is forgotten.

## When seven categories became 43

The same project gave me another version of this lesson. The original scope covered seven product categories across the website, eBay, and Amazon.

Each marketplace required a different set of fields. Our first approach was to pull the schemas, combine the mandatory and optional fields, and hard-code the resulting forms.

For seven categories, that looked reasonable.

Then the client changed the requirement to 43. The first response was to estimate the time needed to hard-code another 36 categories.

I looked at the repetition and asked why we were building every category by hand. The marketplace schemas already described their fields.

We changed the system to pull those schemas at runtime, match the fields in code, and generate the form based on the category and marketplaces the user selected.

After that revision, 43 categories worked. If the client asked for another hundred later, we had a path to support them without another category-by-category project.

The jump from seven to 43 exposed the real unit of work. The category needed to become data that the system could interpret.

## Multiply the design before calling it done

On another project, each user had a separate environment running their AI agent. We wanted the agent to control a browser while the user watched from the UI and took over when needed.

A colleague built the experience and it worked well. The agent controlled the browser, its actions appeared in the UI, and the user could take control.

The design also added two services for each user. Even if the browser path consumed only 300 to 400 MB per user, multiplying that by thousands of users turned it into hundreds of gigabytes.

The UI only had to show the page the agent was using and let the user take control. Streaming an entire browser also carried developer tools, settings, and other things the user would never touch.

We explored a smaller custom UI, lighter communication with the front end, and running the browser service only when someone needed it, started on demand and shut down after an idle period.

We built and tested those optimizations locally. They kept the smooth browser and takeover experience, and gave the system a much better path to scale.

The per-user multiplier belonged in the design before we called the feature finished.

## Trace the whole workflow

A product owner once reported that a user had paid for a background check, but the check was never requested. Their status stayed unchanged, so they could not continue to the service.

Stripe showed the payment. The easy assumption was that the background-check API had changed or our request to it had failed.

I traced the workflow backward.

We charged the user's saved payment method, wrote the payment intent ID to MongoDB, and then handled Stripe's webhook. The webhook used that ID to find the user and start the background check.

Sometimes Stripe delivered the webhook before MongoDB finished its write. The handler searched for the payment intent ID, found nothing, discarded the event, and left the user stuck.

I reordered the workflow so the payment intent came first. Its ID was already there, so we saved it to the database and only then charged the user. The webhook always had a record to match.

I also stopped relying on one perfectly timed delivery. The handler now returns 200 so Stripe does not retry the event, and saves the webhook to the database as pending.

A cron job tries to match it three or four more times. If it still finds nothing, the event stays pending for an admin to review, and it is logged in case we need it later.

The complaint showed where the failure became visible. Tracing backward found the earlier assumption about timing that caused it.

I use the same idea for regression checks. Find every place that calls the code you are changing, then trace the workflows around those callers.

A local fix can change behaviour somewhere else in the system. You have to follow the call far enough to see who else depends on it and what state they expect.

## Put the risks inside the plan

Thinking past the immediate task also changes how I estimate work.

The clean path gives you a best-case number: the API behaves as expected, the existing code has no surprises, the test data is ready, and every assumption is correct.

I never commit to that number as the delivery date.

A useful estimate includes the risks around the work. I write down what we still need to verify, which dependencies are outside our control, and which parts of the system may require regression testing.

I also explain which assumptions the estimate depends on. If one of those assumptions changes, the client can see why the plan changes with it.

This is another reason documentation matters. It keeps the estimate connected to the information we had when we made it.

## The problem is bigger than the ticket

The more systems I work on, the more questions I ask before changing one.

Is the reported problem the cause, or the last symptom in a longer workflow? Which callers depend on this code? What state do they expect? What happens when seven becomes 43, or one user becomes thousands?

I ask the client questions even when they sound obvious. I document the answers. I trace the code around the change, and I put the risks into the plan instead of estimating as if everything will go right.

Years of experience help because they give you more failures to remember. The useful part is the habit of looking beyond the code directly in front of you.

That wider view is what I mean when I say someone thinks like a senior developer.
