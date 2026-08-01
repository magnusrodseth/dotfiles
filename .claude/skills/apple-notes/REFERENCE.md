# Raw AppleScript reference

For work `scripts/notes.sh` does not cover. Everything here is verified against Notes.app on macOS 26 (Darwin 25.5.0); read the live dictionary with `sdef /System/Applications/Notes.app` if something looks off.

## Object model

```
application "Notes"
  default account            -> account          (writable)
  accounts, folders, notes, attachments
  account
    name, id, upgraded (r/o)
    default folder           -> folder           (writable)
    folders, notes
  folder
    name, id, shared (r/o), container (r/o)
    folders (nested), notes
  note
    name                     first line of body, writable
    id (r/o)                 x-coredata://<store-uuid>/ICNote/pNNNN
    body                     HTML, writable
    plaintext (r/o)
    creation date, modification date (r/o)
    password protected, shared (r/o)
    container (r/o), attachments
  attachment
    name, id, container, content identifier, URL, creation/modification date (all r/o)
    made with: make new attachment at <note> with data (POSIX file "/abs/path")
```

Commands: `show <object>` (reveals it in the UI) and `open note location`. That is the entire verb list; everything else is property access on the object model.

## The UTF-8 pattern

Interpolating text into an AppleScript string literal breaks on quotes, backslashes and non-ASCII. Write the string to a file and read it back instead:

```applescript
set theBody to read POSIX file "/tmp/body.html" as «class utf8»
tell application "Notes"
  make new note at (default folder of default account) with properties {body:theBody}
end tell
```

`read` throws on a zero-length file, so guard empty input.

## Never mutate a collection while iterating it

This fails with `-1728 Can't get item 1 of every note`:

```applescript
repeat with n in (notes of f)
  delete n                      -- collection reindexes underneath the loop
end repeat
```

Snapshot the ids first:

```applescript
set ids to id of every note of f
repeat with theId in ids
  delete note id (theId as text)
end repeat
```

The same applies to moving notes or any other mutation inside a `repeat`.

## iCloud sync resurrects deletions

Deleting a folder on an iCloud account can appear to succeed and then reappear seconds later when sync reconciles, bringing its notes with it. Delete the **notes** first, wait, then delete the folder, then re-check:

```bash
notes.sh folders   # confirm it is actually gone
```

Verify after any destructive iCloud operation rather than trusting the return value.

## Machine-readable output

A returned AppleScript list is printed comma-separated, so any name containing a comma is unparseable. Build the output yourself with an explicit delimiter:

```applescript
tell application "Notes"
  set out to ""
  repeat with n in (notes of default folder of default account)
    set out to out & (id of n) & tab & (name of n) & linefeed
  end repeat
  return out
end tell
```

Dates coerce to ISO 8601 with `(modification date of n) as «class isot» as string`.

## Querying

`whose` clauses are pushed into Core Data and are fast (sub-200ms across a few dozen notes):

```applescript
every note whose body contains "runway"          -- case-insensitive substring
every note whose name is "Exact Title"
every note of folder "Notes" of account "iCloud" whose modification date > (current date) - 7 * days
```

Notes are returned newest-modified first by default, so `list` needs no explicit sort.

## Accounts

Several accounts usually exist because Notes creates one per mail account in System Settings, and most hold zero notes. Enumerate before assuming:

```bash
notes.sh accounts
```

Only the account the user actually syncs (normally iCloud) reaches their phone.
