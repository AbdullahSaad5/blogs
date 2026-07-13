# Post 03 — Agent Document Authoring (notes / raw material)

_Topic: making an AI agent generate real docx/pptx/xlsx/pdf reliably._
_IP rule: never name employer / platform / upstream tools. Technique is fair game._
_Process: interview → fragments here → Saad writes spine → Claude tightens → Saad final pass._

---

## THE SPINE (candidate thesis — confirm with Saad)

The story is a reversal, not a build-up. Arc:

1. **Naive path** — agent generates Office docs by writing a 5000-token python-pptx /
   python-docx / openpyxl / WeasyPrint script per document. Long, slow, error-prone, thrashes.
2. **Fix v1: a wrapper lib (`scopien_docgen`)** — thin readable wrappers so the agent writes
   ~5 lines instead of 5000 tokens. `Deck`, `Doc`, `Workbook`, `pdf()`. Each exposes the raw
   object (`.prs`/`.doc`/`.wb`) so you can drop down when needed. Hardened it through real war
   stories (below).
3. **The catch** — the thing that made it easy made it bad. 5-line calls baked default
   layouts/palettes into the API, so every deck came out *identical, generic, templated*. The
   commit that removed it: "the wrapper made AI-generated documents trend generic and templated."
4. **Fix v2: rip the lib out (commit `33303a8`, Jun 24).** Back to the agent driving raw doc
   libraries directly, BUT front-load a **mandatory design brief** (direction / modular scale /
   accent + why / proof-of-difference vs last doc / takeaway-sentence headings / one visual
   motif / per-section layout plan) + a **STYLING.md recipe book** the agent ADAPTS, never
   pastes. Plus **browser-free structural verification** since you can't rasterize Office files.

Contrast that carries the post: **easy vs good. Fewer tokens ≠ better design.** Abstraction
that removes the work also removes the judgment. Very Saad (skeptical, owns the tradeoff,
contrast-driven).

---

## WAR STORIES (mined from git, all real, all Saad's)

### W1. WeasyPrint can't render emoji → thrash loop (commit `01d8663`, Jun 19)
- Broken: agent uses 🚀 emoji in PDF HTML → WeasyPrint renders blank/tofu → agent writes 4+
  fix-scripts trying to rasterize SVG→PNG and swap each emoji for a `file://` image → "PDF
  takes forever" (not render time, the iteration loop).
- Fix: no emoji. Inline Lucide SVG instead — read the `.svg`, replace `currentColor` with the
  hex accent, wrap in a `<span>`. No rasterizing, no `file://`. Local fonts only (no `@import`
  Google Fonts — WeasyPrint tries to fetch and hangs). Build complete, render once.

### W2. Deck.table runs 40 rows off the slide (commit `3227ced`, Jun 19)
- Broken: agent puts 40-50 ranking rows in one slide table → only ~14 visible, rest off the
  bottom → silent data loss.
- Fix: `Deck.table()` auto-paginates. `TABLE_ROWS_PER_SLIDE = 15`, chunk rows, one slide per
  chunk, continuation slides titled "{title} (cont.)", compact row height `Inches(0.32)`,
  styled header repeated per slide.

### W3. XLSX colors invisible + filters broken (commit `c434507`, Jun 23)
- Broken: (a) 6-hex RGB written with openpyxl's default `00` alpha = fully transparent → fills
  invisible, data bars vanish. (b) `autoFilter.ref` set to header row only → sort/filter
  ignores data rows. (c) `data_bar()` took only column letters; short keys ('id','qty')
  misread as letters.
- Fix: normalize to opaque ARGB (`_argb()` prefixes `FF` on 6-hex), autofilter spans full
  data range `A1:{lastcol}{maxrow}`, `_resolve_column()` resolves a registered key→letter
  before treating a string as a letter.

### W4. f-string breaks the build on Python 3.11 (commit `9121a4d`, Jun 23)
- Broken: backslash-escaped quote inside an f-string expression — legal on 3.12+, SyntaxError
  on 3.11. Container runs 3.11. Build fails at import, ZERO pdfs render in the enterprise image.
- Fix: build the quoted string first as a plain f-string, then use it as a repeat multiplier
  in the outer f-string. (`col = f'<col style="width:{even}">'` then `col * n`.)
- Lesson: dev on 3.12, ship on 3.11. Match the runtime.

### W5. Path passed as palette → cryptic NoneType crash (commit `2d33115`, Jun 19)
- Broken: agent calls `Workbook("/tmp/x.xlsx")` (path where palette goes) → `wb.ws` is None →
  `'NoneType' object has no attribute 'title'` → agent thrashes, no idea what's wrong.
- Fix: harden the builders. `_coerce_palette()` accepts None / Palette / '#hex', else raises a
  TypeError that NAMES the fix ("pass the path to .save(), not the constructor"). Workbook keeps
  a valid default sheet so `wb.ws` always works. Icon lookup raises a ValueError naming the fix.
- Lesson: the agent is the user. Error messages are the docs. A cryptic error = an hour of agent
  thrash; a guiding error = self-correct in one step.

---

## VERIFICATION + THE REVIEWER LOOP (how v2 buys safety back without the wrapper)
The reviewer is NOT a separate agent. It's a **self-review step inside the same skill/session**:
build → review → fix → review → ... → satisfied → hand to user. Two kinds of review:

1. **Structural checks** via a CLI (`officecli`) — works on every format, cheap:
   - `view ... issues --json` flags low-contrast, broken-refs, unresolved-fields, overflow.
   - `view ... outline` confirms heading nest / slide order / titles.
   - xlsx: grep formulas for `#REF!`/`#DIV/0!` before save, then `issues --json` after calc.
2. **Render-and-look (visual) review** — the agent actually SEES the output as an image:
   - **PDF + diagrams: already live, cheap.** `pdftoppm -png -r 55` → low-DPI contact sheet,
     read whole doc at once, zoom a page at `-r 110` for detail. graphviz `dot` for diagrams.
   - **Office (pptx/docx/xlsx): achievable and PROVEN, but gated on cost.** Rasterize with
     LibreOffice headless: `soffice --headless --convert-to pdf` then `pdftoppm` → one image
     of all N slides, hand back to the agent to look at. Saad has run this; it works. THE CATCH:
     **LibreOffice adds ~400MB to the container image.** That's a heavy dependency for one
     feature, so it's currently a **fallback, not the default** — actively hunting a lighter
     middle ground. Until then the deck/doc path leans on structural checks + a mental review
     against the brief. (The current skill files still say "Office can't rasterize here" because
     LibreOffice isn't in that image yet — that's a deployment choice, not a hard limit.)

- Honest framing for the post: the visual loop is real and proven; the 400MB image bloat is why
  it isn't on by default. Owning that tradeoff = the senior-practitioner voice. Defensible live.

## DESIGN-FIRST (the v2 replacement for the wrapper)
- Every skill front-loads a mandatory design brief (Python comment block) BEFORE any build code:
  direction (tech/editorial/luxe/bold), ONE modular scale, accent + why, proof-of-difference vs
  last doc (change >=2 of 3), takeaway-sentence headings, ONE visual motif, per-section layout
  plan (>=3 distinct blocks, none adjacent-alike).
- 60/30/10 color rule: ~60% neutral, ~30% ink, ~10% accent on EXACTLY ONE focal element.
- "A deck built only from {cover -> stats -> table} comes out generic and soulless — the #1
  failure here." That sentence is basically the post's thesis from the inside.
- STYLING.md per format = recipe book. Agent copies a snippet as a headstart, then CHANGES
  colors/fonts/sizes/structure. Paste-verbatim is the failure mode.

## FP&A xlsx convention (nice concrete detail)
- Blue font = input, black = formula, green = cross-sheet link, red = external, yellow fill =
  key assumption. Numbers as numbers, formulas as formulas (never hand-typed totals). Native
  charts over a Reference (live, editable), not a static PNG. DataBarRule not unicode blocks.

---

## THE BEFORE/AFTER (centerpiece — same deck assignment, "World's 100 Wealthiest")
Two real artifacts. Wrapper version = `1782316239914-deck.pptx` (12 slides). Raw+brief version
= `1782328523215-top100_billionaires.pptx` (10 slides). The difference is VISIBLE, not vibes:

1. **Headings: labels vs takeaways.** Wrapper: "THE SCALE", "Country Breakdown", section "01"
   (topic labels). Raw+brief: "Musk alone holds more wealth than the next 14 combined", "The
   United States dominates", "Wealth knows no single flag" (takeaway SENTENCES, the conclusion).
2. **The table tell (the smoking gun).** Wrapper deck dumps a 20-row ranking into a table that
   AUTO-SPLITS into a "(cont.)" slide — that is literally the Deck.table pagination feature (W2)
   firing. Raw+brief deck has NO table dump; it turns the ranking into charts + a hero stat
   slide. => the war story (auto-paginate long tables) was a SYMPTOM: the wrapper made "paste
   the table" the path of least resistance. The brief made the agent ask "what's the story in
   this data" instead of "paste the rows." The bug fix and the disease are the same thing.
3. **Cover.** Wrapper: dark charcoal, orange rule on the left, big serif left-aligned, subtitle
   has an EM-DASH ("net worth — Forbes"). Raw+brief: cream/luxe, centered, gold accent rule,
   giant ghost "100" numeral motif behind the title, clean cited date.
4. **Opening & soul.** Wrapper opens flat: "$6.5 trillion sits in the hands of 100 people."
   Raw+brief opens with an angle: "The $20 Trillion Club", then a Musk hero "RICHEST HUMAN BEING
   IN HISTORY / $839B / 3x richer than #2 / +$497B in a single year." It picked the story.
5. **Motif & close.** Raw+brief carries the ghost-numeral motif and ends on a statement slide
   ("Wealth has never been this concentrated. 3,428 billionaires. $20.1T. One person holds $839B").
   Wrapper just ends on "THE TOP 100 IN SIX NUMBERS" (a stats recap).

Use this side-by-side as the visual proof in the post (lists, not tables, for Medium). The
single sharpest line: the wrapper's marquee feature (auto-paginate a 20-row table) existed only
because the wrapper trained the agent to dump tables. Kill the wrapper, the agent stops dumping.

## INTERVIEW LOG (fragments from Saad — fill during grilling)

- **Spine = A (the reversal).** "Built the abstraction, it worked, then deleted it." Thesis:
  fewer tokens != better design; the wrapper removed the work AND the judgment.

- **The cost was real, owned openly:** tokens went back up (5 lines -> big scripts again),
  so docs got pricier AND slower to generate. Variance went up, docs came back broken again.
  Saad accepts all of it. The trade was worth it.

- **Why worth it:** with the wrapper every document "looked the same, it lacked a soul. Just a
  generic document built by the same agent, no creativity." Removing the templates is what
  brought the creativity back. "The bugs can be resolved... but the creativity is back, and I
  think that was the main thing."

- **THE CORE INSIGHT (post's beating heart):** agents are results-driven by default. The wrapper
  produced *a* document, so the agent thought it was done. "Because there was a document. Not a
  good one, but it was one. So it thought it was good." The template let the agent DECLARE VICTORY
  on a soulless doc. Take the template away and the agent is forced to be creative. The constraint
  IS the creativity mechanism. (Abstraction didn't just make output generic — it let the agent
  stop thinking.)

- **Bought back safety with a REVIEWER / feedback loop:** variance/broken-doc problem solved not
  by going back to the wrapper, but by adding a reviewer. Reviewer inspects the output, flags
  what's broken, agent fixes it, verify-before-push-to-user loop. Safety moved from "the library
  prevents the bug" to "the loop catches the bug."

- **Known bugs became agent guidance, not library code:** table overflow, transparent fills,
  emoji-tofu etc. -> we tell the agent up front "these are pitfalls we've hit, stay clear." The
  hard-won fixes moved from code (the wrapper) into the skill docs / pitfall list. Ongoing:
  watching for common pitfalls and advising the agent as we find them.

- **Reviewer = self-review step in the SAME session, not a second agent.** Build -> review ->
  fix -> review -> ... -> satisfied -> hand to user. Reviews two ways: structural (officecli:
  broken refs, overflow, low contrast) on every format, AND visual render-and-look where the
  agent sees an image of all N slides at once. Visual loop is live+cheap for PDF; for Office
  it's LibreOffice headless (proven, Saad's run it) but +400MB image, so it's a fallback while
  we look for a lighter middle ground. The loop is how v2 got safety back WITHOUT the wrapper.

## FINAL DECISIONS (locked in interview)
- **Cold open = the same-deck realization.** Open on the symptom: asked for a deck, got a deck,
  every time the SAME deck, couldn't say why at first. NOT the 5000-token-thrash scene.
- **Audience = broader-with-teeth** (matches posts 01/02). War stories told AS STORIES (named,
  not code-quoted). Lead with the results-driven-agent insight. Light on python-pptx internals.
