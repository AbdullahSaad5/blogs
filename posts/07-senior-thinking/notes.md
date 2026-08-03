# 07 — "How to think like a senior engineer" (seeing beyond what's in front of you)

_Raw material from the grill-me interview. The quarry — fill during the session, then shape into
draft.md. Opinion essay, not a technical deep-dive. Must end up in Saad's words._

Genre: opinion / personal essay. Lever: traction + personal brand (same lever as post 04).
Hook/vantage: insider who ships agent/full-stack systems where the unseen case is the one that bites.

## Thesis (from PLAN.md, to be tested in the interview)
Not about title or years. About the habit of thinking past the immediate change: second-order
effects, failure modes nobody asked about, blast radius, what breaks at 10x, who else touches this.
The senior move = reasoning about what you *can't* see in the diff.

RISK: don't preach. Show the habit via concrete moments where thinking-beyond caught something.
Not a listicle of virtues.

## Candidate stories (seeds from PLAN — confirm/replace in interview)
- Key-exchange (post 05): "a leaked key re-mints itself forever" — seeing the hole before it shipped.
- Plan mode (post 02): classifying destructive steps before executing them.
- Post 04: the proration / grandfathering cases the AI never raised.

---

## Interview capture
_(war stories, concrete moments, opinions, lines worth keeping — fill as we go)_

### What senior thinking means to Saad

- A senior developer documents everything.
- A junior developer tends to focus on the reported problem. A senior first asks whether the
  reported problem is the actual problem or only a symptom of something deeper.
- Before fixing something, a senior asks how the fix will affect the rest of the system. The
  immediate code change is only one part of the work.
- A practical regression check: find every place that calls the code being changed, then trace
  what each caller and the workflows around it will affect.
- Do not assume. Assumptions create problems, especially when the developer and client think they
  agreed but are picturing different behaviour.
- Ask questions even when they sound dumb. The goal is to make sure the developer and client are
  describing the same thing.
- Always perform a risk assessment.
- Never estimate delivery as if everything will go right. The estimate should account for the
  risks and unknowns that could affect the work.

### Emerging spine

The difference is scope of thought. The junior sees the reported problem and the code immediately
in front of them. The senior traces backward to the cause, outward through the system, and forward
into the risks of both the change and the delivery plan.

Documentation and questions make that wider reasoning visible. They expose assumptions early and
give everyone a shared record of what was decided, what could go wrong, and why.

### Story 1: seven categories became 43

The project let an e-commerce operator enter a product listing once, then choose whether to publish
it to the client's website, eBay, Amazon, or some combination of them.

The initial requirement covered seven categories. The junior developers pulled the eBay and Amazon
schemas, found the mandatory and optional fields, and planned to hard-code a union of those fields
into the portal's listing form.

That approach worked for seven categories. Then the client changed the requirement to 43.

The juniors treated the change as 36 more versions of the same manual task and asked for more time
to hard-code them. Saad changed the question: why encode every schema manually when the application
could pull the marketplace schemas at runtime, match the fields in code, and generate the form?

The team revised the implementation and automated the schema handling. The result supported all 43
categories and created an extension path. If the client later asked for 100 more, the system could
handle them without another category-by-category implementation project.

Potential lesson: when the requested quantity jumps, do not only recalculate the estimate. Revisit
the unit of work. Repetition in the plan may be evidence that the real task is to build a mechanism.

### Story 2: browser control worked, but scaled per user

In another project, every user had a separate container that ran their AI agent. The team wanted to
give each agent browser control while showing its actions in the UI. The user also needed to be able
to take over control.

A colleague implemented the browser-control experience successfully. The immediate feature worked:
the agent controlled a browser, its activity appeared in the UI, and the user could take over.

The problem appeared when Saad multiplied the design by the user count. The implementation required
two per-user services. Even at roughly 300–400 MB of RAM, that becomes expensive across thousands
of users.

Saad explored ways to preserve the experience while reducing the per-user cost:

- Replace the full browser UI with a small custom UI that renders only what users need to see.
- Remove browser chrome such as developer tools and settings from the streamed experience.
- Investigate lighter communication between the browser service and the front end.
- Compare screenshots with lower-bandwidth approaches, including sending DOM/state for a front-end
  renderer. (Need technical confirmation before publishing.)
- Explore headless execution and ways to expose only the rendered browser surface.
- Start the browser service only when a user needs it, similar to an on-demand function.
- Shut the service down after an idle period so inactive users consume no browser-service memory.

After several optimizations, the team preserved the smooth browser-control and takeover experience
while producing a design that could scale across many users.

Potential lesson: “the feature works” only proves the single-user path. A senior also changes the
multiplier and asks which resource grows once per user, request, job, or tenant.

### How the stories fit the article

1. The marketplace story shows thinking past the requested quantity and finding the underlying
   repeatable mechanism.
2. The browser story shows thinking outward from a working feature into resource cost and scale.
3. Documentation, questions, caller tracing, and risk assessment can become the repeatable method
   after the stories establish why it matters.

### Story 3: “the background check did not run” was a race condition

One service charged a newly signed-up user for a background check. After payment, the application
requested the check from an external provider. When the result arrived days later, the application
updated the user's status and decided whether they could proceed to the service.

A product owner reported that one user had paid but their background check had not been completed.
Stripe showed a successful payment, but the rest of the workflow had not happened.

A narrow investigation could have started by assuming that an external API had changed or that the
background-check request needed to be retried. Saad traced the workflow backward instead.

The failure was a race condition between the Stripe webhook and MongoDB. The webhook could arrive
before the application's database write had saved the user's payment intent ID. The webhook handler
then tried to find the user by that ID, found nothing, discarded the event, and never started the
background check or updated the user's status.

The visible complaint was accurate but incomplete: “I paid and nothing happened.” The deeper
failure was that the workflow assumed the database write would always finish before the external
event returned.

Need to confirm:

- “Workbook” in the interview means Stripe webhook.
- Whether failed events were permanently lost before the fix.

Potential opening: start with the product owner's report, follow the tempting API-level
investigation, then reveal the timing gap. This directly demonstrates the backward question:
is the reported problem the defect, or the last visible symptom of it?

#### Confirmed fix

The original sequence charged the user's saved payment method first, then updated MongoDB with the
payment data. Saad flipped the order: create/update the database record first, then create the
charge. That ensured the webhook had a record to match when it arrived.

He also made the webhook path tolerate a temporarily missing record. Stripe already retries failed
webhook deliveries with backoff, so the handler allowed roughly three or four attempts before
settling the event. The design no longer depended on one perfectly timed delivery.

The fix had two layers:

1. Remove the known race by persisting the correlation data before initiating the external action.
2. Keep retries on the receiving side because external events can still arrive out of order or
   before local state is ready.

---

“Document everything” does not mean documenting every line of code. Record the decisions another
person may need to understand later: requirements, assumptions, risks, rejected alternatives, and
the reason one approach was chosen.

The useful test is whether someone could return to the work later and understand what the team
believed, what it decided, and what could go wrong without reconstructing the entire conversation.

---

The e-commerce project started with one form. The operator entered a product's information,
images, inventory, and listing details together. The system then created the catalog entry, added
the stock, and published the selected listings.

The team assumed those four things belonged to one workflow because the client had described them
together. Nobody stopped to verify the relationship between a product, a batch of stock, and a
marketplace listing.

At the demo, the client said the model was wrong. A product catalog entry needed to exist once.
Every new shipment should create another batch of stock against that product, without entering the
same product information again.

Listings had a separate lifetime too. The client might create ten listings against the same stock,
and later create more listings without rebuilding the catalog. A depleted stock batch should not
automatically hide the listing because the business accepted order leads and could source more
stock after an order arrived.

The form worked according to the team's model. The model was based on assumptions the client had
never confirmed. After a long implementation, the team had to rebuild it.

Possible core line: assumptions become architecture very quickly. By the time the client sees the
wrong assumption in a demo, it may already exist in the database model, API, form, inventory
workflow, and listing logic.
