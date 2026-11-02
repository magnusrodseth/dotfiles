# Desktop branch

Load the installed CLI's workflow and the current OS guide before operating an app:

```bash
agent-desktop skills get desktop
agent-desktop skills get platform
agent-desktop status
agent-desktop permissions
```

Use `agent-desktop <command> --help` for flags. Load the relevant embedded command reference when handling menus, input delivery, waits, or screenshots. Do not assume macOS behavior applies on Windows or Linux.

## Bind and observe

Select a unique task namespace and pass `--session` consistently. A namespace separates snapshots and refs, not the physical desktop. Other agents and the user can still change the app.

```bash
agent-desktop --session TASK list-apps
agent-desktop --session TASK list-windows --app 'APP NAME'
agent-desktop --session TASK snapshot --app 'APP NAME' -i --compact
```

Replace `TASK` and `APP NAME` with actual values. Choose among observed windows by title and ID. With no matching window, check whether the requested app needs opening. Do not treat `WINDOW_NOT_FOUND` as a permission failure.

Carry the selected `--window-id` into subsequent snapshots and screenshots. A successful app-name snapshot does not guarantee that a screenshot selects the same window. On `AMBIGUOUS_TARGET`, use the returned candidate IDs and titles.

For dense apps, use `snapshot --skeleton` and drill into a returned container ref with `--root`. A menu, sheet, popover, or alert is the next target when it overlays the window. Use the platform guide's supported `--surface` and refresh its tree.

## Act and check delivery

Pass the complete ref returned by the snapshot, including its snapshot ID. Never shorten it to a browser-style `@eN`. Keep the same session scope on later calls.

Default to headless semantic actions. These do not authorize synthesized input or focus changes. Physical actions such as hover or drag require `--headed` and explicit user permission under the upstream workflow. Do not silently switch modes after a headless failure.

Parse the JSON envelope. Both errors and action results can carry a delivery disposition. Retry or substitute an action only when `disposition.retry` is `safe`. Otherwise observe the current state and decide from evidence; the first attempt may have landed.

Refresh after UI changes. Handle `STALE_REF`, `AMBIGUOUS_TARGET`, and `SNAPSHOT_NOT_FOUND` by observing and selecting a valid target. If several elements match, narrow by role, exact name, root, or window. A successful accessibility call still needs verification in the app.

Prefer explicit `check` and `uncheck` over `toggle` when setting a known state. Inspect partial field input before sending more text. Use the installed workflow to choose replacement versus append behavior.

## Visual input

```bash
agent-desktop --session TASK screenshot --app 'APP NAME' /absolute/path/window.png
```

Choose a private temporary output path and view the image. Read the current screenshot and interaction command help before coordinate input. Confirm whether coordinates refer to a display or window; never transfer coordinates from another backend or a resized image.

Screenshots need the OS permission reported by `permissions`. Do not enable tracing, screenshot sessions, or public uploads by default. Clipboard use can affect the user's data; prefer semantic field actions and avoid overwriting their clipboard to work around a failure.

## Crossing into a browser

Use desktop control for native browser UI and OS dialogs. When returning to `agent-browser`, confirm the actual browser, session, tab, and final URL. Discard desktop refs for browser actions and refresh the browser snapshot. An independently launched CLI browser is a separate context even when its app name matches.
