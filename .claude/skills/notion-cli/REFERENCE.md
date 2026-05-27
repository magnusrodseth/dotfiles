# Notion CLI Reference

Deep-dive details for the `ntn` CLI workflows in [SKILL.md](SKILL.md). Consult this when you hit a gotcha, need a JSON shape, or need to expand on a workflow.

## Authentication

`ntn` has two parallel auth mechanisms:

| Mechanism | Used by | How to obtain |
|---|---|---|
| `NOTION_API_TOKEN` env var | `ntn pages`, `ntn files`, `ntn api` | Create an "Internal integration" at https://www.notion.so/profile/integrations, copy the secret |
| OAuth via `ntn login` | `ntn workers` | Run `ntn login`, opens a browser |

For everything except `ntn workers`, only the env var is needed. The integration must be invited to each target page or database (`...` menu → "Connect to integration").

### Token discovery

If the user's shell exports the token under a different name (commonly `NOTION_API_KEY`), search before failing:

```bash
grep -l NOTION ~/dotfiles/zsh/ignored/*.sh 2>/dev/null
```

Then map:

```bash
export NOTION_API_TOKEN="${NOTION_API_TOKEN:-$NOTION_API_KEY}"
```

### Verifying auth

`ntn api v1/users` returns `403 restricted_resource` for personal integration tokens; that is **expected** and not an auth failure. Verify against a real resource instead:

```bash
ntn api v1/data_sources/<known-data-source-id>
```

A `200` with the schema confirms the integration has access to that resource.

## `ntn api` inline body syntax

`ntn api` builds the request body from inline `key=value` arguments. Two variants:

- `field=string-value` — always a string
- `field:=10` / `field:=[...]` / `field:=null` — typed JSON literal (numbers, arrays, objects, booleans, null)
- `nested[child][sub]=value` — nested object key

For complex bodies (multi-line, big arrays), use stdin instead:

```bash
echo '{"properties":{...}}' | ntn api v1/pages/<id> -X PATCH
```

Or `--data '{...}'`. Method defaults to GET; auto-promotes to POST when a body is present; `-X PATCH` / `-X DELETE` always wins.

## Property formats

Each property in `properties:=` is keyed by **property name** (not ID). The value shape depends on the property type. Get the schema first with `ntn api v1/data_sources/<id>` if unsure.

```jsonc
{
  // Title (every database has exactly one)
  "Name": {
    "title": [{"text": {"content": "My title"}}]
  },
  // Status
  "Status": {
    "status": {"name": "Kladd"}
  },
  // Select
  "Category": {
    "select": {"name": "Engineering"}
  },
  // Multi-select
  "Tags": {
    "multi_select": [{"name": "agentic"}, {"name": "tokens"}]
  },
  // Date
  "PublishedAt": {
    "date": {"start": "2026-05-27"}
  },
  // URL / email / phone
  "Url": {"url": "https://example.com"},
  // Number
  "Score": {"number": 42},
  // Checkbox
  "Featured": {"checkbox": true},
  // Rich text
  "Summary": {
    "rich_text": [{"text": {"content": "Short summary"}}]
  }
}
```

## Block JSON shapes

Image block with file upload (the most common shape after running `ntn files create`):

```json
{
  "object": "block",
  "type": "image",
  "image": {
    "type": "file_upload",
    "file_upload": {"id": "<UPLOAD_ID>"},
    "caption": [{"type": "text", "text": {"content": "Caption text"}}]
  }
}
```

Image block with external URL:

```json
{
  "object": "block",
  "type": "image",
  "image": {
    "type": "external",
    "external": {"url": "https://example.com/photo.png"},
    "caption": [{"type": "text", "text": {"content": "Caption"}}]
  }
}
```

Paragraph (useful as a sentinel block for ordering):

```json
{
  "object": "block",
  "type": "paragraph",
  "paragraph": {
    "rich_text": [{"type": "text", "text": {"content": "Hello"}}]
  }
}
```

Heading variants follow the same pattern with type `heading_1`, `heading_2`, `heading_3` and the matching nested key.

## The `after` parameter and API version

`PATCH /v1/blocks/{id}/children` supports an optional `after` parameter to insert blocks at a specific position. This field was removed in newer API versions; you must request the older one:

```bash
ntn api "v1/blocks/$PAGE_ID/children" -X PATCH \
  --notion-version 2022-06-28 \
  children:='[...]' \
  after=<BLOCK_ID>
```

Without `--notion-version 2022-06-28`, Notion responds:

```
400 validation_error: body failed validation: body.after should be not present
```

Without `after`, new children are appended to the end of the parent. There is **no `before` parameter** in any version.

## Inserting blocks at the top

Notion has no native "prepend". To put a block at the very top of a page:

1. Prepend a sentinel paragraph to the markdown before creating the page (plain alphanumeric only, e.g. `BANNERANKER`).
2. After the page is created, list its blocks and find the sentinel by `plain_text` match.
3. PATCH the new block with `after=<sentinel_id>`.
4. DELETE the sentinel block with `ntn api v1/blocks/<sentinel_id> -X DELETE`.

**Why plain alphanumeric**: Notion strips markdown punctuation (underscores, asterisks, backticks) from `plain_text`. A sentinel like `___BANNER___` becomes `BANNER` in the block's text, breaking exact-match lookups.

## H1 stripping in database pages

When `ntn pages create --parent data-source:<id>` receives markdown that begins with a `# Heading`, that heading is **dropped** from the body — the data source's title property is expected to carry the title. To keep an in-body heading at the top, either:

- Use `## Heading` (heading_2) instead
- Prepend any non-heading content (e.g. a sentinel paragraph) before the `# Heading`, which causes the H1 to be preserved

## Why markdown `![]()` cannot reference file uploads

`ntn pages create` parses markdown image syntax `![alt](url)`. The URL is treated as an external URL; if it doesn't resolve to a valid URL Notion recognizes, the image block is created with `image.type = "external"` and an empty `external.url`. The alt text becomes the block's caption.

Notion's API does **not** allow `PATCH /v1/blocks/{id}` to change `image.type` (`external` → `file_upload` is rejected with a validation error). To attach an uploaded file as an image:

- Delete the empty external image block, then insert a new image block with `image.type = "file_upload"`, **or**
- Skip markdown image syntax entirely and create the image blocks via API after the page exists

The helper script at `scripts/markdown-to-page.py` uses the second strategy.

## File upload lifecycle

`ntn files create` returns an upload with `status: "uploaded"` and `expiry_time` one hour later. During that hour the upload is "staged" — usable in any block that references `file_upload.id`. Once a block referencing the upload is created, the file is persisted in the workspace and the `expiry_time` no longer matters.

If multiple uploads are needed, batch them in parallel (`ntn files create` is independent per file) but make sure all blocks referencing them are created within an hour of the first upload.

## Useful read patterns

List children of a page or block:

```bash
ntn api "v1/blocks/$PAGE_ID/children" \
  | jq -r '.results[] | "\(.id) [\(.type)] \(.[.type].rich_text[0].plain_text // "")"'
```

Get full markdown of a page (useful for round-trip testing):

```bash
ntn pages get <PAGE_ID>
```

Search by title in a data source:

```bash
ntn api "v1/data_sources/<DS_ID>/query" -X POST \
  filter:='{"property":"Name","title":{"contains":"Token"}}'
```

## Cleanup

Trash a page non-interactively:

```bash
ntn pages trash <PAGE_ID> --yes
```

There is no "untrash" via CLI; restore from Notion's UI Trash.

## Doctor and updates

```bash
ntn doctor           # checks CLI version, config, default workspace
ntn update           # self-update
ntn --version        # current version
```
