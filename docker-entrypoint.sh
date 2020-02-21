#!/bin/bash

set -e
# Exit on fail

echo "Starting Redis service"
redis-server --daemonize yes

exec "$@"
