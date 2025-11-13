# See https://hub.docker.com/_/debian/tags?name=bookworm for latest version
FROM node:20.19.5-trixie-slim

# Install dependencies
# see latest versions with make list-apt-versions
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  curl wget git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV SHELL="/bin/sh"
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable
RUN ENV=$HOME/.shrc pnpm add -g nushell

# Create non-root user
RUN adduser appuser && \
  #Install Claude Code globally
  # See latest version at https://www.npmjs.com/package/@anthropic-ai/claude-code
  pnpm add -g @anthropic-ai/claude-code@2.0.37


# Create directories and set permissions
# COPY .zshrc /home/appuser/.zshrc
RUN chown -R appuser:appuser /home/appuser

# Create app directory and set ownership
WORKDIR /workspace
RUN chown -R appuser:appuser /workspace

# Switch to non-root user
USER appuser

ENTRYPOINT ["/pnpm/claude"]
