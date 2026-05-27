---
description: Update pi and installed pi packages
---
## Context

- Current pi version: !`pi --version`
- Installed pi packages: !`pi list`

## Task

1. Run `pi update`.
2. If the self-update step fails, run `npm install -g @earendil-works/pi-coding-agent` and then retry `pi update`.
3. Summarize:
   - the pi version after updating
   - which packages were updated
   - any warnings or manual follow-up items
4. Do not modify project files unless I explicitly ask.
