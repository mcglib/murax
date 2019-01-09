#!/bin/bash

set -e
# Exit on fail

cd /usr/src/app
echo "Ensure all gems are installed"
bundle check || bundle install --binstubs="$BUNDLE_BIN"
# Ensure all gems installed. Add binstubs to bin which has been added to PATH in Dockerfile.

Echo "Starting Redis service"
redis-server --daemonize yes

Echo "Starting Apache service"
service apache2 stop
service apache2 start

Echo "Starting sidekiq service"
bundle exec sidekiq
exec "$@"
# Finally call command issued to the docker service
