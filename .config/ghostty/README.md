# Ghostty Config

Shared settings live in `config`. Machine-specific overrides go in `config.local`, which is gitignored so each machine keeps its own.

The main `config` ends with:

```
config-file = ?config.local
```

The `?` prefix makes the file optional, so ghostty will not warn if it is missing.

Because `config-file` is processed at the end, any key set in `config.local` overrides the same key in `config`.

## Per-machine setup

After cloning the dotfiles and running `stow .`, create `~/.config/ghostty/config.local` with the values that differ per machine. At minimum, set the working directory to the user's home:

### Personal Mac

```
working-directory = /Users/magnusrodseth/dev
```

### Gjensidige Mac

```
working-directory = /Users/magnus.rodseth/dev
```

Add any other machine-specific keys (font size, window size, theme, etc.) to the same file.

## Verifying

Open ghostty and confirm new windows open in the expected directory. To inspect the merged config, run:

```
ghostty +show-config
```
