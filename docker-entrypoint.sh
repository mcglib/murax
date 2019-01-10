#!/bin/bash

set -e
# Exit on fail

cd /usr/src/app
echo "Ensure all gems are installed"
bundle check || bundle install --binstubs="$BUNDLE_BIN"
# Ensure all gems installed. Add binstubs to bin which has been added to PATH in Dockerfile.

exec "$@"
