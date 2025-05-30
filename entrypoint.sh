#!/usr/bin/env bash
set -e

# if we were passed any arguments, just run them
if [ $# -gt 0 ]; then
  exec "$@"
fi

# in production env, migrate the db and warm the flickr redis cache
if [ "$RAILS_ENV" = "production" ]; then
  ./release-tasks.sh
fi

# start web server
exec bundle exec puma -C config/puma.rb