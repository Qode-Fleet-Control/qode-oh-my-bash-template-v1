# Oh My Bash template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with a
Oh My Bash starter laid on top. **A job, not a service**: the image's default command runs the
check and exits 0 on success; nothing listens on `$PORT`.

## What it is

A versioned bash setup (`VERSION`, currently 1.0.0) on [Oh My Bash](https://ohmybash.nntoan.com):

| path | what |
|---|---|
| `bash/.bashrc` | the rc file — theme, plugins, completions, aliases; no self-update |
| `bash/custom/plugins/qode/qode.plugin.sh` | the setup's own plugin (`qode_hello`, `mkcd`, `ll`) |
| `bash/custom/themes/qode/qode.theme.sh` | the setup's own theme: `qode <cwd> (<branch>*) $` |
| `scripts/install.sh` | installs Oh My Bash at a pinned commit (official installer, `--prefix` mode) |
| `scripts/check.sh` | **the job**: interactive bash with this rc file, checks the setup loaded |

`.bashrc` points `OSH_CUSTOM` at its own `custom/` directory, so the repo is the single
source of the setup. In the image `~/.bashrc` is a symlink to it.

## Run it

**With docker** (what the fleet does):

    docker compose build
    docker compose run --rm app          # the check; exit 0 = setup loaded
    docker compose run --rm app bash     # try the shell itself

**Without docker** (needs bash 4+, git, curl; your `~/.bashrc` is left alone):

    bash scripts/install.sh              # = fleet.conf INSTALL_CMD -> ./.local/share/oh-my-bash
    bash scripts/check.sh
    OSH="$PWD/.local/share/oh-my-bash" bash --rcfile bash/.bashrc   # use it

## Origin

Oh My Bash's official installer, pinned to commit `abf846186ab0a8a41ec5888e827ece6277dfe446`
(scripts/install.sh):

    bash install.sh --unattended --prefix=<prefix>   # install.sh from raw.githubusercontent.com/ohmybash/oh-my-bash/<commit>/tools/install.sh

The bash setup itself (`bash/`) is hand-written to Oh My Bash's customisation layout
(`$OSH_CUSTOM/plugins/<name>/<name>.plugin.sh`, `$OSH_CUSTOM/themes/<name>/<name>.theme.sh`)
and its template `.bashrc`.

## Deviations from stock output, and why

- **`--prefix` install instead of the per-user one.** The per-user mode moves your
  `~/.bashrc` aside and writes its template there; `--prefix` only clones (into
  `<prefix>/share/oh-my-bash`), so the versioned `.bashrc` here stays the source and a
  local install never touches your dotfiles.
- **Pinned commit.** The installer clones `master`; `scripts/install.sh` then checks out
  the pinned commit and `.bashrc` sets `DISABLE_AUTO_UPDATE`.
## Verified

**The docker image has NOT been built or run yet**: on 2026-10-05 the shared build host's docker disk was full (0-2 GB free for over 8 hours), so `docker compose build` was never attempted. Run `docker compose build && docker compose run --rm app` once before trusting it.

Without docker (2026-10-05, bash 5.2, throwaway `$HOME`): `bash scripts/install.sh`
installed Oh My Bash at the pinned commit into `./.local/share/oh-my-bash`, and
`bash scripts/check.sh` passed — oh-my-bash, git + qode plugins, qode theme, prompt
renders, nothing unexpected on stderr. `$HOME` was left untouched.


## Fleet lifecycle

`fleet.conf` drives every script in `bin/` (see `docs/fleet-lifecycle.md`). On the fleet
the docker runtime runs `DOCKER_BUILD_CMD` (`docker compose build`) and, because this is
a job and not a service, stops there: `DOCKER_START_CMD` is empty, the same as
`START_CMD`. Run the job itself with `docker compose run --rm app`.

    ./bin/run                    # docker runtime: builds the image, then stops (no server)
    docker compose run --rm app  # runs the job; exit code 0 = pass
    FLEET_RUNTIME=process ./bin/run   # no docker: runs INSTALL_CMD, then stops at start

`bin/run` ends with the template's own "no START_CMD" message — that is intentional.

## Serving over HTTP

Fleet apps are served at the root of their own hostname
(`https://<hash>.<FLEET_APP_DOMAIN>/`). **This repo has no HTTP surface**: `PORT`,
`HEALTH_PATH` and `START_CMD` are empty and `compose.yaml` publishes nothing. If you add
an HTTP endpoint, listen on `0.0.0.0:$PORT` (read at runtime), serve at `/`, set `PORT`,
`HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD='docker compose up --remove-orphans'`
in `fleet.conf`, and publish `"${PORT:-N}:${PORT:-N}"` in `compose.yaml`.

`compose.yaml` passes the fleet's variables (`DATABASE_URL`, `REDIS_URL`, `S3_*`,
`SMTP_*` …) through to the container without values; this template reads none of them.
