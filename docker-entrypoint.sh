#!/bin/bash

set -e
# Exit on fail

cd /storage/www/murax/current
echo "Ensure all gems are installed"
bundle check || bundle install --binstubs="$BUNDLE_BIN"
# Ensure all gems installed. Add binstubs to bin which has been added to PATH in Dockerfile.

echo "Starting Redis service"
redis-server --daemonize yes

echo "Starting Apache service"
service apache2 stop
service apache2 start

exec "$@"
