# GitHub notification reference

Consult the linked official docs when behavior or authentication differs from this reference. Use current UI labels for browser work.

## Repository modes and delivery

| Mode | Effect |
|---|---|
| Participating and @mentions | Notifications from participation or mentions; existing thread subscriptions can remain |
| All Activity | Broad repository notifications |
| Custom | Selected event types plus participation and @mentions |
| Ignore | Blocks repository notifications, including participation and mentions |

Account delivery settings live at [Notification settings](https://github.com/settings/notifications). Repo subscriptions live at [Watching](https://github.com/watching). Individual conversation subscriptions live at [Subscriptions](https://github.com/notifications/subscriptions).

Read the live category descriptions. GitHub groups Custom events with Participating and @mentions in the delivery UI. Enabling that category's Email channel can email participation in other repos too. Repository event selection does not establish an independent email channel for that repo.

For a strict email allowlist, explain this limit and propose mail filtering as a separate task. Do not simulate it by ignoring every other repository. Unwatching a repo also does not remove all existing conversation subscriptions.

Actions, Dependabot, agent sessions, and other system notifications have separate settings. Read these for an email audit; alter them only within the user's chosen scope.

If automatic watching controls are available, inspect them when auditing an opt-in policy. Changing defaults does not clean up existing subscriptions. Treat cleanup as an explicit repository list and target modes.

## CLI branch

Use `gh auth status` and `gh api user --jq .login` to verify the account. Keep credentials in `gh`'s store.

Replace the illustrative `OWNER/REPO` below with the verified repository. Quote endpoint arguments. Check installed CLI help or current official docs when syntax is uncertain.

```bash
# Verify repository access separately from subscription state.
gh api 'repos/OWNER/REPO' --jq '{full_name,html_url}'

# List repository subscriptions across all pages.
gh api --paginate user/subscriptions --jq '.[].full_name'

# Read a simple repository subscription.
gh api 'repos/OWNER/REPO/subscription' --jq '{subscribed,ignored,reason}'

# All Activity.
gh api --method PUT 'repos/OWNER/REPO/subscription' \
  -F subscribed=true -F ignored=false

# Stop watching; return to participation and mentions.
gh api --method DELETE 'repos/OWNER/REPO/subscription'

# Ignore, only when explicitly requested.
gh api --method PUT 'repos/OWNER/REPO/subscription' \
  -F subscribed=false -F ignored=true
```

Use typed `-F` booleans. `-f` sends strings. These mutation examples require the user's selected action and repository.

A subscription GET can return 404 for no subscription. Confirm repository access first; a missing or inaccessible repo can also return 404. Treat 403 as an access failure.

After PUT, GET must match the selected booleans. After DELETE, the subscription should be absent while the repo remains accessible. Re-read the UI when clearing an Ignore or Custom mode.

The REST subscription endpoint exposes `subscribed` and `ignored`, with no Custom event selectors. Use the UI to inspect or edit Custom, and for global email delivery. Treat the paginated CLI list as a repository inventory, not a full inventory of ignored modes, Custom events, or thread subscriptions.

If authentication is unsupported by the endpoint, use Brave with the same account. Explain the limitation before requesting broader credentials. Never print tokens.

## Browser branch

Use Brave Personal unless the user chooses another browser. Name one browser session before opening or claiming tabs.

- For Custom: open the verified repo, open Watch/Unwatch, then Custom. Read the selected events before editing. Apply only the chosen selection. Reload, reopen Custom, verify every checked event, and close the dialog without another save.
- For delivery: open Notification settings, read each affected category and selected channels, edit the chosen channels, and save. Verify the resulting category labels after reload.
- For audit: inspect settings and subscriptions without saving. Cancel preview dialogs. Current settings are live account state; keep them out of the skill files.

## Official sources

- [Configure notifications](https://docs.github.com/en/subscriptions-and-notifications/get-started/configuring-notifications)
- [REST watching endpoints](https://docs.github.com/en/rest/activity/watching)
- [View subscriptions](https://docs.github.com/en/subscriptions-and-notifications/how-tos/managing-subscriptions-for-activity-on-github/viewing-your-subscriptions)
- [GitHub CLI API reference](https://cli.github.com/manual/gh_api)
