FROM ruby:4.0.9

ARG USER_NAME=user
ARG USER_UID=1000
ARG USER_GID=1000

RUN addgroup --gid $USER_GID $USER_NAME && \
    adduser --disabled-password --gecos '' --uid $USER_UID --gid $USER_GID $USER_NAME

# Install Docker CLI + buildx (for Kamal deployments)
RUN curl -fsSL https://get.docker.com | sh && \
    groupadd -g 999 docker || true && \
    usermod -aG docker $USER_NAME

# Install system dependencies for curb gem
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential pkg-config libcurl4-openssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Lighthouse for the performance specs (spec/performance): Node and Chromium
# from Debian, Lighthouse at the version pinned in tools/lighthouse.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends nodejs npm chromium fonts-liberation && \
    rm -rf /var/lib/apt/lists/*
COPY tools/lighthouse/package.json tools/lighthouse/package-lock.json /opt/lighthouse/
RUN cd /opt/lighthouse && npm ci --omit=dev --no-audit --no-fund
ENV CHROME_PATH=/usr/bin/chromium

WORKDIR /app
