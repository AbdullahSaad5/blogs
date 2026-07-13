#!/usr/bin/env bash
# Publish a dev.to post from a markdown file (front-matter + body in one file).
# Creates a NEW article. Whether it goes live or stays a draft is decided by the
# `published:` line in the file's front matter (devto.md is published: false = draft).
#
# Usage:
#   DEV_TO_API_KEY=your_key bash publish-devto.sh posts/02-plan-mode/devto.md
#
# The key is read from the environment only. It is never written to disk or echoed.

set -euo pipefail

FILE="${1:?usage: DEV_TO_API_KEY=key bash publish-devto.sh <path/to/devto.md>}"
: "${DEV_TO_API_KEY:?set DEV_TO_API_KEY in the environment (it is not stored anywhere)}"

[ -f "$FILE" ] || { echo "no such file: $FILE" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required (brew install jq)" >&2; exit 1; }

# Build the request body safely: jq escapes the entire markdown (front matter included).
BODY=$(jq -Rs '{article: {body_markdown: .}}' < "$FILE")

RESP=$(curl -sS -X POST "https://dev.to/api/articles" \
  -H "api-key: ${DEV_TO_API_KEY}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.forem.api-v1+json" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36" \
  -d "$BODY")

# Report the result.
echo "$RESP" | jq -e '.id' >/dev/null 2>&1 || { echo "FAILED:"; echo "$RESP" | jq . 2>/dev/null || echo "$RESP"; exit 1; }

echo "Created dev.to article:"
echo "$RESP" | jq '{id, title, published, url, edit_url: ("https://dev.to/dashboard")}'
echo
echo "It is a DRAFT (published:false). Open https://dev.to/dashboard to review, add a cover, then publish."
