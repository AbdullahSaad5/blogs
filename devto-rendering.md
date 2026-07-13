# dev.to (Forem) rendering reference

What the dev.to markdown editor renders and what it silently drops. Forem runs its own
markdown parser, not GitHub's, so a few things that work on GitHub fail here. Test before
trusting anything marked "varies".

Sources: [dev.to editor guide](https://dev.to/p/editor_guide),
[Forem markdown](https://dev.to/devcorner/markdown-cheatsheet-guide-256n),
[native mermaid post](https://dev.to/marcelo_earth/enhance-your-readmes-with-native-mermaid-diagrams-3g7l).

## Front matter (required first block)

```yaml
---
title: Your title
published: false        # false = draft, true = live
description: SEO + social preview blurb
tags: ai, llm, agents, security   # max 4, lowercase, no spaces inside a tag
cover_image: https://...          # 1000x420 recommended. URL only, see "Images" below
canonical_url: https://your-site.com/post   # point back at your own site
series: Series name               # groups posts, auto nav
---
```

## Renders natively (safe)

| Feature | Syntax | Notes |
|---|---|---|
| Headings | `# H1` .. `###### H6` | one H1 max per post |
| Bold / italic | `**b**` `_i_` | |
| Strikethrough | `~~text~~` | |
| Inline code | `` `code` `` | |
| Code blocks | ` ```lang ` | syntax highlighting by language tag |
| Tables | GFM pipe tables | render fine despite not being in the guide |
| Task lists | `- [ ]` / `- [x]` | |
| Footnotes | `[^1]` + `[^1]: note` | supported, but test |
| Blockquote | `> ` | |
| Links / jump links | `[t](url)` , `## H <a name="x"></a>` | anchor for in-page TOC |
| Images | `![alt](url)` | + `<figcaption>` for captions |
| HTML comment | `<!-- hidden -->` | not shown |

## Liquid tags (Forem-specific, powerful)

Universal embed: `{% embed https://... %}` auto-detects the platform.

Native embeds: YouTube, Twitter/X, GitHub (gist/issue/repo), CodePen, Glitch, Replit,
CodeSandbox, JSFiddle, StackBlitz, Twitch, Vimeo, Instagram, Spotify, SoundCloud, Reddit,
Medium, Loom, Asciinema.

DEV-specific:
- `{% link URL %}` — article card
- `{% user name %}` , `{% tag name %}` , `{% organization name %}`
- `{% podcast URL %}`

Interactive blocks:
- `{% details summary %}` ... `{% enddetails %}` — collapsible
- `{% spoiler summary %}` ... `{% endspoiler %}`
- `{% card %}` ... `{% endcard %}`
- `{% cta link %}` ... `{% endcta %}` — call to action button

Math (KaTeX):
- block: `{% katex %}` ... `{% endkatex %}`
- inline: `{% katex inline %}` ... `{% endkatex %}`
- raw `$$ ... $$` is NOT reliable. Use the liquid tag.

## Does NOT render (the traps)

| Wanted | Reality | Do this instead |
|---|---|---|
| **Mermaid** ` ```mermaid ` | renders as raw code. No native support, no liquid tag | render to image via **mermaid.ink** or kroki.io, embed `![](url)`. See recipe below |
| Raw `$$ math $$` | inconsistent | `{% katex %}` liquid tag |
| Arbitrary HTML/CSS/JS | sanitized, most stripped | use liquid tags or images |
| GitHub `> [!NOTE]` callouts | plain quote | use `{% details %}` or bold lead-in |
| Auto TOC | none | hand-build with jump links |

## Mermaid recipe (what we use)

Forem will not render `` ```mermaid `` blocks. Render server-side to an image and embed it.

```bash
# 1. write the mermaid source to a .mmd file
# 2. base64-encode it into a mermaid.ink URL
B=$(base64 < diagram.mmd | tr -d '\n')
echo "https://mermaid.ink/img/$B?type=png&bgColor=FFFFFF"
# 3. embed in the post:  ![diagram alt text](that-url)
```

Gotchas learned the hard way:
- mermaid.ink returns **404 on a parse error**, not an error image. If you get 404, your
  mermaid syntax is broken. The stadium shape `(["text"])` broke it; plain `["text"]` works.
- `<br/>` inside node labels works fine.
- A node wrapped in a `subgraph` makes incoming arrows pierce the box and land ugly. Prefer a
  labeled dashed edge (`A -. "label" .-> B`) over a subgraph when you just want to mark a boundary.
- mermaid.ink is an external dependency. For a portfolio/job-hunt post you care about long-term,
  also keep the rendered PNG and **upload it into the dev.to editor** (drag-drop) so the image
  lives on dev.to's CDN instead of relying on mermaid.ink uptime. Then swap the `![](mermaid.ink...)`
  URL for the dev.to-hosted one.

## Images and covers

- The dev.to **API cannot upload images.** `cover_image` in front matter must already be a URL.
- To host an image on dev.to: open the post in the web editor, drag the file into the body (or
  the cover slot), dev.to uploads it and gives you a `https://media.dev.to/...` URL.
- Cover can be added/changed **after** publishing. Publishing coverless is reversible.
- Keep canonical post + diagrams in this repo; dev.to is a republish target.
- **Setting the cover via API:** upload the image in the editor first to get an
  `https://dev-to-uploads.s3...` URL, then put it in the `cover_image` front-matter line inside
  `body_markdown` and PUT. The top-level `main_image` field is **ignored on update** (returns
  `cover_image: None`). Only the front-matter `cover_image` takes.

## Publishing via API

```
PUT https://dev.to/api/articles/{id}
headers: api-key, Content-Type: application/json,
         Accept: application/vnd.forem.api-v1+json,
         User-Agent: <real browser UA>     # Cloudflare 403s the default urllib UA
body: {"article": {"body_markdown": "...", "published": true}}
```

`published: true` flips a draft live. `published: false` keeps it a draft. Everything else
(title, tags, cover) is editable post-publish from the editor.
