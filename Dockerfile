FROM ruby:4.0.9-slim AS base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      pkg-config \
      libcurl4-openssl-dev \
      libjemalloc2 && \
    rm -rf /var/lib/apt/lists/*

# jemalloc instead of glibc malloc: Puma's threads fragment glibc's arenas,
# so workers grow for hours. Same settings as eventer. Measured with the whole
# sitemap, 4 rounds, 8 at a time: 2 workers + master 231 -> 180 MiB PSS.
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
ENV MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true"

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4

COPY . .

EXPOSE 4567

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
