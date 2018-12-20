# Pull base image.
FROM ubuntu:16.04
LABEL maintainer="dev.library@mcgill.ca"

# Minimal requirements to run a Rails app
RUN apt-get update
RUN apt-get install -y clamav git

ENV APP_PATH /usr/src/app

# Different layer for gems installation
WORKDIR $APP_PATH
#ADD Gemfile $APP_PATH
#ADD Gemfile.lock $APP_PATH
#RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

# Copy the application into the container
COPY . APP_PATH
EXPOSE 3000
