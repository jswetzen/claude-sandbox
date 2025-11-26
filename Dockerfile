# See https://hub.docker.com/_/debian/tags?name=bookworm for latest version
FROM node:20.19.5-trixie-slim

# Install dependencies
# see latest versions with make list-apt-versions
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  curl wget git ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Get uv
RUN curl -LsSf https://astral.sh/uv/0.9.11/install.sh | sh && mv /root/.local/bin/uv* /usr/bin/

ENV SHELL="/bin/sh"
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
# Set display port for Chrome
ENV DISPLAY=:99

RUN corepack enable
RUN ENV=$HOME/.shrc pnpm add -g nushell

# Create non-root user
# RUN adduser appuser --uid 1000 --gid 1000 && \
# RUN adduser appuser && \
  #Install Claude Code globally
  # See latest version at https://www.npmjs.com/package/@anthropic-ai/claude-code
RUN pnpm add -g @anthropic-ai/claude-code@2.0.37


# Create directories and set permissions
# COPY .zshrc /home/appuser/.zshrc
RUN chown -R node:node /home/node

# Create app directory and set ownership
WORKDIR /workspace
RUN chown -R node:node /workspace

# Switch to non-root user
USER node

ENTRYPOINT ["/pnpm/claude"]
