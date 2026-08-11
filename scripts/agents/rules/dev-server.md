If a project ships an agent-friendly dev command (a background launcher with
idempotent status/stop, e.g. `make dev` / `make dev-status` / `make dev-stop`
in hei-huset-agent), use it: those are safe for me to start, query, and stop.
Otherwise, when servers are run manually in separate terminals, assume they're
already running and don't launch them in the foreground (a foreground `dev`
blocks indefinitely).
