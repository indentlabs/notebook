#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /home/notebookai/tmp/pids/server.pid

# Ensure the database is prepared (migrated & seeded) before starting the server
bundle exec rails db:prepare
bundle exec rails db:seed

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
