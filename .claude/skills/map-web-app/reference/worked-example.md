# Worked example: mapping Hevy (22.08.2026)

A real run of the process, including what went wrong. The artifact it produced is the `hevy-training` skill in the Obsidian vault.

## Phase 0: the five-minute check that saved hours

Hevy has a documented REST API at `api.hevyapp.com`, and `hevy.com/settings?developer` shows a **Generate API Key** button. Both facts point at "use the API".

Clicking it returns: *"Our API is only available with Hevy Pro."* The account is free. Probing `/api/v1/routines` from the page returned `InvalidApiKey`.

**Cost of finding out: three minutes. Cost of not finding out: designing a whole CLI against an API that returns 401.**

The inverse also matters: this is now the first line of the skill, so no future agent re-investigates.

## Phase 1: the model

| Entity | List | Detail | Edit |
|---|---|---|---|
| Routine | `/routines` | `/routine/<shortid>` | `/edit-routine/<uuid>` |

**The edit URL uses a different id from the detail URL.** Detail is `DxMrbbur75D`, edit is a UUID. Nesting: routine → exercises → sets, each set having weight and reps.

## Phase 2: CRUD, including the awkward one

List, read and create were straightforward. **Delete was not on the detail page at all**: it lives behind a `···` on the routine card, and that button has **no accessible name**, so it had to be located geometrically (a 24px `svg` in a known x-range). That is documented as fragile.

**The limit surfaced by accident**: creating a fifth routine opened "Routine Limit Reached. Free accounts are limited to 4." Better to have found this deliberately.

## Phase 3: three widget traps in one form

1. **The note field is a `textarea`, not an `input`.** A selector reading `input[placeholder="Add pinned note"]` matched zero elements. `.fill()` on it threw nothing useful.
2. **The note carries a placeholder**, so the filter `input:not([placeholder])` excluded it. An earlier assumption that "index 0 of the unplaceheld inputs is the note" was simply wrong; index 0 is an unrelated empty input.
3. **Bodyweight exercises have no weight column.** Set rows are `[kg, reps]` for loaded exercises and `[reps]` for bodyweight ones. Fixed-stride index arithmetic wrote reps into the weight column and looked plausible in the summary.
4. **The rest timer is a react-select**, not a `<select>`. It needs click-control-then-click-option, and reads back from `div[class*="-singleValue"]`.

## Phase 4: the silent failure, in full

The first notes implementation ran clean. The CLI printed `created ZZ Note Test`, exit code 0. The routine appeared with the right exercises, sets and reps.

**Every note was empty.**

The selector matched nothing, `.fill()` on a zero-count locator did nothing observable, and the save succeeded because the rest of the form was valid. Nothing in the write path indicated failure.

It was caught only by reading the values back **through the edit view**, which is a different path from the one that wrote them. The routine *detail* page does not render notes at all, so verifying there would have proved nothing either way.

**Generalised rule: a write is unverified until it has been read back through an independent view.**

## Phase 5: the two artifacts

- `scripts/hevy` — `export`, `routines list|show|create|delete`, plus offline analysis (`last`, `prs`, `stats`) that reads the CSV and needs no browser.
- `reference/selectors.md` — stable anchors, the fragile hashed class with its derivation snippet, every trap above, and the Phase 0 finding.

Creates take a JSON spec rather than flags, so a routine is a reviewable, re-runnable file.

## Phase 6: what the round trip caught

`create → verify → delete` on a throwaway record caught the empty-notes bug before it reached the real routines.

It also caught a **foreground timeout corrupting a record**: a create loop with rest timers exceeds two minutes, and killing it mid-flow left a half-built routine that still listed as if it existed. Long UI writes must be backgrounded.

## The bonus finding

Building the CSV parser produced an independent check on a claim already in the vault: an earlier AutoGluon analysis had found the real lifting cadence was 1.2 sessions/week against an assumed 2.7. The new parser, written from scratch, reported 1.23. Two tools, two methods, same answer.

**Mapping a system properly tends to validate or refute things you already believed about it.** That is a reason to do it even when a one-off script would have sufficed.

## Extraction trick worth stealing

Hevy's CSV export is built client-side and attached to an `<a download>` with a `data:` URL. Letting the click through opens a **native OS save dialog**, which no browser-automation tool can dismiss.

Fix: swallow the click and fetch the href in-page.

```js
await page.evaluate(() => {
  window.__csv = null;
  const orig = HTMLAnchorElement.prototype.click;
  HTMLAnchorElement.prototype.click = function () {
    if (this.hasAttribute('download')) {
      fetch(this.href).then(r => r.text()).then(t => { window.__csv = t; });
      return;                       // never reaches the browser downloader
    }
    return orig.call(this);
  };
});
```

Then poll `window.__csv`. Works for `data:` and `blob:` hrefs alike, and generalises to any client-side export. Note that `URL.createObjectURL` interception covers only the Blob case and would have found nothing here.
