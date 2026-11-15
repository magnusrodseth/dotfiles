# Web watch reference

## Create body

Every watch uses the vault's cloud environment and the vault repo as its source. The repo gives it the setup script, which installs Playwright and Chromium.

```json
{
  "name": "<Name>",
  "cron_expression": "0 7,17 * * *",
  "enabled": true,
  "job_config": {"ccr": {
    "environment_id": "env_013EVBpnQxS2Xk5GJv2pm5Li",
    "events": [{"data": {"message": {"content": "<prompt from TEMPLATE.md>", "role": "user"},
      "parent_tool_use_id": null, "session_id": "", "type": "user", "uuid": "<new uuid4>"}}],
    "session_context": {
      "allowed_tools": ["Bash", "Read", "mcp__Gmail__send_message"],
      "model": "claude-haiku-5-5",
      "sources": [{"git_repository": {"url": "https://github.com/magnusrodseth/vault"}}]
    }
  }},
  "mcp_connections": [{"connector_uuid": "e248a032-a811-4617-9f6a-65ec40848ebe",
    "name": "Gmail", "url": "https://gmailmcp.googleapis.com/mcp/v1"}]
}
```

| Choice | Rule |
|---|---|
| Model | `claude-haiku-5-5` when one page is parsed against fixed markers. `claude-sonnet-5-5` when the watch reads several sites, compares prices or judges relevance |
| Tools | Add `Write` for Playwright scripts. Add `mcp__Gmail__search_threads` and `mcp__Gmail__get_thread` for the history block. Add `WebSearch` only if the watch must find pages itself |
| Cron | Runs in UTC. Oslo is UTC+1 in winter and UTC+2 in summer, so 08:00 Oslo is `0 7` in winter |
| Update | `RemoteTrigger update` with the full `job_config.ccr`, including `events` with its `uuid`. Read the routine with `get` first |
| Pause | `update` with `{"enabled": false}`. Do this when the end condition is met or Magnus has acted on the hit |

## When the page cannot be read

The cloud cannot read pages behind a Cloudflare check, a captcha or a login. Offer these alternatives, in order:

1. **The site's own alert.** Many shops have «varsle meg» or price alerts, and Prisjakt has «prisvarsel». Magnus turns it on once. The watch then reads the alert email through Gmail (`search_threads` on the sender) instead of the page.
2. **Another source** for the same fact: the brand's own shop, another retailer, or an RSS or JSON feed the page loads. Probe it the same way.
3. **Exa** (`web_fetch_exa`) works from the cloud with no egress rules. It returns a cached copy, so use it only for slow-changing facts and never for stock.

Known blockers, verified 15.11.2026: Prisjakt shows a Cloudflare check to headless Chromium from both the home IP and the cloud. Norli answers 403 from the cloud. Norwegian and SAS can block the datacenter IP. Fjellsport, Løplabbet, KitchenTime and Hetzner loaded from the cloud.

## Finding stock markers

Size pickers are hard to read headless. Look for JSON-LD first: `"@type":"Offer"` objects carry `availability` (`InStock`, `LimitedAvailability`, `SoldOut`) and a `url` per variant, and plain `curl` gets them. Map a variant to its size by opening its URL and reading the selected size. On Fjellsport, `?variantId=<sku>` selects the size, and the page then shows «Legg i handlekurv» when it is in stock or «Sett varsling på varen» when it is sold out.

## Watches running today

List them with `RemoteTrigger list`. Hetzner CX-varsel is the minimal single-page example. «Prisvakt: ønskelisten» is the multi-site example with Gmail history and a weekly report.
