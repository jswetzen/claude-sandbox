# Multi-stage build: Get Chrome and ChromeDriver from official Selenium image
FROM docker.io/selenium/standalone-chrome:latest AS selenium

# See https://hub.docker.com/_/debian/tags?name=bookworm for latest version
FROM docker.io/node:20.19.5-trixie-slim

# Install dependencies
# see latest versions with make list-apt-versions
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  curl wget git git-lfs make zsh \
  ca-certificates build-essential \
  # Chrome dependencies
  fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 \
  libatspi2.0-0 libcups2 libdbus-1-3 libdrm2 libgbm1 \
  libgtk-3-0 libnspr4 libnss3 libwayland-client0 \
  libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 \
  libxrandr2 xdg-utils libu2f-udev libvulkan1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Initialize git-lfs system-wide
RUN git lfs install --system

# Copy Chrome and ChromeDriver from Selenium image
COPY --from=selenium /opt/google/chrome /opt/google/chrome
COPY --from=selenium /usr/bin/google-chrome /usr/bin/google-chrome
COPY --from=selenium /usr/bin/chromedriver /usr/bin/chromedriver

# Create symlinks for chrome
RUN ln -s /opt/google/chrome/chrome /usr/bin/chrome

# Get uv
RUN curl -LsSf https://astral.sh/uv/0.9.11/install.sh | sh && mv /root/.local/bin/uv* /usr/bin/

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
# Set display port for Chrome
ENV DISPLAY=:99
ENV SHELL="/bin/sh"

RUN corepack enable
RUN ENV=$HOME/.shrc pnpm add -g nushell

# Install Claude Code via native installer, then move to system-wide location
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    mv /root/.local/share/claude /usr/local/share/claude && \
    ln -sf /usr/local/share/claude/versions/$(ls /usr/local/share/claude/versions/) /usr/local/bin/claude && \
    chmod 755 /usr/local/bin/claude

# Create directories and set permissions
RUN chown -R node:node /home/node

# Create app directory and set ownership
WORKDIR /workspace
RUN chown -R node:node /workspace

# Switch to non-root user
USER node

ENTRYPOINT ["/usr/local/bin/claude"]
