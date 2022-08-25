FROM ruby:2.7-alpine

# Install alpine packages
RUN apk add --no-cache \
    build-base \
    busybox \
    ca-certificates \
    sqlite-dev \
    cmake \
    curl \
    git \
    tzdata \
    graphicsmagick \
    libffi-dev \
    libsodium-dev \
    nodejs \
    yarn \
    sqlite \
    openssh-client \
    postgresql-dev \
    tzdata
#install bash
RUN apk add --no-cache bash

# Define WORKDIR
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

RUN mkdir -p $WORKDIR/vendor/bundle

RUN gem install capistrano bundler sshkit-sudo whenever sitemap_generator capistrano-passenger capistrano-bundler capistrano-sidekiq capistrano-npm  capistrano-rbenv capistrano-locally capistrano-rails capistrano-ssh-doctor capistrano-safe-deploy-to --no-document

# Copy dependency manifest
COPY Gemfile Gemfile.lock $WORKDIR/

RUN bundle update --bundler
RUN bundle config set path $WORKDIR/vendor/bundle
RUN bundle install --jobs $(nproc) --retry 3 --without development test \
    && rm -rf /usr/local/bundle/bundler/gems/*/.git /usr/local/bundle/cache/

# Define entrypoint
ENTRYPOINT ["/bin/bash"]

