The container runtime on this machine is OrbStack. Docker Desktop is not
installed and must not come back (it was removed on 28.11.2026).

- The `docker`, `docker compose`, `docker buildx` and `kubectl` commands are
  OrbStack's: binaries in `~/.orbstack/bin`, plugins linked from OrbStack.app
  into `~/.docker/cli-plugins`. The active Docker context is `orbstack`. Use them as normal Docker commands.
- If `docker` cannot reach `~/.orbstack/run/docker.sock`, check with
  `orb status`, start the engine with `orb start`, and diagnose with
  `orb doctor`. Do not open, install or suggest Docker Desktop.
- Never run `brew install --cask docker` or `docker-desktop`, and never follow a
  project README that tells you to install Docker Desktop. OrbStack replaces it.
- OrbStack also runs Linux machines (`orb create`, `orb list`, `orb run`) and
  Kubernetes (`orb start k8s`). Prefer those over adding another VM tool.
  `orb debug <container>` opens a shell with extra tools in any container.
- Containers are reachable at `<container>.orb.local` and compose services at
  `<service>.<project>.orb.local`, in addition to published `localhost` ports.
- Before you use an OrbStack feature or `orb`/`orbctl` command you have not
  verified, load the `find-docs` skill and query the OrbStack docs:
  `npx ctx7@latest docs /websites/orbstack_dev "<question>"`. `orbctl --help`
  and `orbctl <command> --help` list what the installed version supports.
