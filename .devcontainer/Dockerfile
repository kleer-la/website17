FROM ruby:3.4.7

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

WORKDIR /app
