# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# A job image, not a server: Oh My Bash is installed in the image (official installer,
# pinned commit — scripts/install.sh) for a non-root user, ~/.bashrc is this repo's
# bash/.bashrc, and the default command starts an interactive bash and checks that the
# setup loaded (scripts/check.sh). Exits 0 when it did.

FROM debian:bookworm-slim
ARG BUILD_ID=""
RUN apt-get update \
 && apt-get install -y --no-install-recommends bash git curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 10001 -s /bin/bash app && mkdir /app && chown app:app /app
ENV BUILD_ID=$BUILD_ID OSH=/home/app/.local/share/oh-my-bash TERM=xterm-256color

WORKDIR /app
USER app
COPY --chown=app:app . .
RUN PREFIX=/home/app/.local bash scripts/install.sh \
 && ln -sf /app/bash/.bashrc /home/app/.bashrc
CMD ["bash", "scripts/check.sh"]
