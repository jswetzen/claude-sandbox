# Multi-stage build: Get Chrome and ChromeDriver from official Selenium image
FROM docker.io/selenium/standalone-chrome:latest AS selenium

# See https://hub.docker.com/_/debian/tags?name=bookworm for latest version
FROM docker.io/node:20.19.5-trixie-slim

# Install dependencies
# see latest versions with make list-apt-versions
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  curl wget git ca-certificates build-essential \
  # Chrome dependencies
  fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 \
  libatspi2.0-0 libcups2 libdbus-1-3 libdrm2 libgbm1 \
  libgtk-3-0 libnspr4 libnss3 libwayland-client0 \
  libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 \
  libxrandr2 xdg-utils libu2f-udev libvulkan1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy Chrome and ChromeDriver from Selenium image
COPY --from=selenium /opt/google/chrome /opt/google/chrome
COPY --from=selenium /usr/bin/google-chrome /usr/bin/google-chrome
COPY --from=selenium /usr/bin/chromedriver /usr/bin/chromedriver

# Create symlinks for chrome
RUN ln -s /opt/google/chrome/chrome /usr/bin/chrome

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
RUN pnpm add -g @anthropic-ai/claude-code@2.1.49


# Create directories and set permissions
# COPY .zshrc /home/appuser/.zshrc
RUN chown -R node:node /home/node

# Create app directory and set ownership
WORKDIR /workspace
RUN chown -R node:node /workspace

# Switch to non-root user
USER node

ENTRYPOINT ["/pnpm/claude"]
