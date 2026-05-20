#!/usr/bin/env bash
set -e

# if we were passed any arguments, just run them
if [ $# -gt 0 ]; then
  exec "$@"
fi

# in production env, run release tasks before starting the web server
if [ "$RAILS_ENV" = "production" ]; then
  ./release-tasks.sh
fi

# start web server
exec bundle exec puma -C config/puma.rb
