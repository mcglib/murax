FROM ruby:2.7

RUN apt-get update && apt-get install -y \
        ca-certificates \
        cmake \ 
        curl \
        git \
        bash \
        tzdata

# Define WORKDIR
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

RUN mkdir -p $WORKDIR/vendor/bundle
RUN gem install capistrano -v 3.11.2

RUN gem install bundler sshkit-sudo whenever sitemap_generator capistrano-passenger capistrano-bundler capistrano-sidekiq capistrano-npm  capistrano-rbenv capistrano-locally capistrano-rails capistrano-ssh-doctor capistrano-safe-deploy-to --no-document

# Copy dependency manifest
COPY Gemfile Gemfile.lock $WORKDIR/

RUN bundle update --bundler
RUN bundle config set path $WORKDIR/vendor/bundle
RUN bundle install --jobs $(nproc) --retry 3 --without development test \
    && rm -rf /usr/local/bundle/bundler/gems/*/.git /usr/local/bundle/cache/

# Define entrypoint
# Define basic environment variables
ENV NODE_ENV production
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
#
#ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD "/bin/bash"
