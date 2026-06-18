# `op` command reference

Fuller catalog for tasks beyond the SKILL.md quick paths. All examples assume
`export OP_ACCOUNT=my.1password.eu` (personal) unless noted. Add `--account
capragroup.1password.eu` for work. Confirm exact flags with `op <cmd> --help` —
they drift between versions (this machine: `op` 2.30.0).

## Accounts & auth

```bash
op account list                         # all configured accounts (addr, email, user id)
op whoami --account my.1password.eu     # may say "not signed in" under app integration — fine
op signin --account my.1password.eu     # only needed if NOT using desktop app integration
```

Known accounts on this machine:

| Role     | Sign-in address         | Email                     |
|----------|-------------------------|---------------------------|
| Personal | `my.1password.eu`       | magnus.rodseth@gmail.com  |
| Work     | `capragroup.1password.eu` | mar@capraconsulting.no  |

Target an account per command with `--account <addr>`, or for a whole session with
`export OP_ACCOUNT=<addr>`. Keep work and personal explicit so secrets don't cross.

## Vaults

```bash
op vault list
op vault get Development
op vault list --account capragroup.1password.eu   # work vaults
```

## Finding & reading items

```bash
op item list                                   # all items in the (env) account, table
op item list --vault Private                    # scope to a vault
op item list --categories "API Credential"      # filter by category
op item list --tags dev                          # filter by tag
op item get "Cargo API Token"                    # human-readable, MASKS concealed fields
op item get <itemID> --format json               # full structure incl. `reference` per field
op item get GitHub --fields label=username       # specific field(s)
op item get GitHub --fields label=password --reveal   # reveal concealed value (avoid printing)
op read "op://Private/Cargo API Token/token"     # resolve a single secret reference
op read "op://Private/Cargo API Token/token" -o /tmp/tok && chmod 600 /tmp/tok  # to a file
```

Prefer `scripts/op-fields.sh "<item>" [vault]` to discover field labels and `op://`
references with all values masked — safe to show the user.

## Categories seen in this account

`LOGIN` (most items), `SECURE_NOTE`, `API_CREDENTIAL`, `PASSWORD`, `CREDIT_CARD`,
`IDENTITY`. All current API credentials (GitHub PATs, OpenAI API Key, AWS, Cargo token)
live in the `Private` vault.

## Injecting secrets

```bash
# Template file with op:// references, e.g. .env.tpl:
#   DATABASE_URL=op://Development/db/url
#   OPENAI_API_KEY=op://Private/OpenAI API Key/credential
op inject -i .env.tpl -o .env          # write resolved file (MUST be gitignored)
op inject -i config.tpl | some-cmd     # stream resolved output into a command
op run --env-file=.env.tpl -- ./app    # set env vars for the child process only (nothing on disk)
op run --env-file=.env.tpl -- printenv OPENAI_API_KEY   # debugging: confirm a var resolves
```

`op run` is the safest for running apps: secrets exist only in the child process's
environment. Use `op inject -o` only when a tool truly needs a real file, and gitignore it.

## Creating & editing items

```bash
# Generate a login with a random password and store it
op item create --category login --title "Example" --vault Private \
  --url https://example.com username=me --generate-password='letters,digits,symbols,32'

# API credential with a custom field
op item create --category "API Credential" --title "My Service" --vault Private \
  'credential[password]=PUT-VALUE-HERE'

# From a template piped via stdin (assignments override template values)
op item template get Login | op item create --vault Private -

# Edit fields / rotate a password
op item edit "Example" --vault Private username=new.name
op item edit "Example" --vault Private --generate-password='letters,digits,symbols,32'

# Section.field assignment
op item edit "My Service" 'credentials.personal_token[password]=NEW'

op item delete "Example" --vault Private     # remove (use --archive to archive instead)
```

Field assignment syntax: `label=value`, typed `label[password]=value` / `label[text]=value`,
sectioned `section.label=value`. Discover existing labels with `op item get <item> --format json`.

## Documents

```bash
op document list
op document get "<title>" --output ./file.pdf
op document create ./file.pdf --title "<title>" --vault Private
```

## SSH & Git (1Password agent)

This machine has the 1Password app; it can serve SSH keys via its agent and sign Git
commits. Manage SSH keys stored as items:

```bash
op item list --categories "SSH Key"
op item get "<ssh key title>" --fields "public key"
```

Enabling the SSH agent / Git commit signing is configured in the 1Password app
(Settings → Developer), not via `op`. See https://developer.1password.com/docs/ssh/.

## Output formats & scripting

```bash
op item get <item> --format json | jq '.fields[] | {label, reference}'
op item list --format json
op --version
op <command> --help          # authoritative flags for THIS installed version
```

## Shell plugins

```bash
op plugin list               # configured plugins (cargo, openai here; gh disabled)
op plugin init <tool>        # set up a new biometric-backed CLI plugin
op plugin run -- <tool> ...  # run a tool through its plugin without the alias
op plugin clear              # clear cached plugin credentials
```

Config lives in `~/.config/op/plugins.sh` (aliases) and `~/.config/op/plugins/`
(per-tool JSON). That whole directory is gitignored. The `source` line in `.zshrc`
is commented out — uncomment to activate the `cargo`/`openai` aliases.

## Troubleshooting

| Symptom                                   | Cause / fix                                                       |
|-------------------------------------------|------------------------------------------------------------------|
| `account is not signed in` from `op whoami` | Normal under desktop app integration; data commands still work. |
| `authorization timeout`                   | Touch ID prompt not approved in time — rerun and approve fast.   |
| `[ERROR] could not find vault/item`       | Wrong account — set `--account`/`OP_ACCOUNT`; titles are case-sensitive. |
| App integration not prompting at all      | Enable it in 1Password app → Settings → Developer → "Integrate with 1Password CLI". |
