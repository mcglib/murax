From ruby:2.7
RUN apt-get update && apt-get install cmake -y
RUN gem install capistrano bundler sshkit-sudo whenever sitemap_generator capistrano-passenger capistrano-bundler capistrano-sidekiq capistrano-npm  capistrano-rbenv capistrano-locally capistrano-rails capistrano-ssh-doctor capistrano-safe-deploy-to --no-document
RUN mkdir /usr/local/murax
RUN mkdir -p /usr/local/murax/vendor/bundle
RUN bundle config set path /usr/local/murax/vendor/bundle
COPY Gemfile /usr/local/murax/.
WORKDIR /usr/local/murax/
RUN bundle install
