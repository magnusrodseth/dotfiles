Pick the browser by what the page needs, also inside T3 Code. When Magnus names a
browser, use that one.

- **Logged-in sites, or anything that needs his extensions** (1Password and
  others): use `playwriter`. It drives his real Brave through the Playwriter
  extension, with his cookies and extensions. He sees the tab in Brave and can
  take over there. Start every session with `--tab-group <task>`. When
  `playwriter browser list` shows more than one browser, pass the Brave row's key
  (`install:Brave:<id>`, different per machine) as `--browser <key>`. Work in a
  tab you opened, and never act on his other tabs. If the extension rejects the
  CLI version, run `npm install -g playwriter@latest`.
- **Local dev servers and public pages, when he wants to watch inline**: use T3's
  built-in browser, the preview tab driven by the `t3-browser` skill. Its profiles
  are separate Electron sessions: no browser extensions, no real logins, no
  1Password.
- **Headless or parallel work with no login**: `agent-browser` with a named
  session.
