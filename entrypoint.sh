#!/usr/bin/env bash
set -e

# in production env, migrate the db and warm the flickr redis cache
if [ "$RAILS_ENV" = "production" ]; then
  echo "---- Release phase starting via entrypoint.sh ----"
  bundle exec rails db:migrate && echo "db:migrate finished"
  bundle exec rails cache_warmer:flickr && echo "cache_warmer done"
  echo "---- Release phase complete ----"
fi

# start web server
exec bundle exec puma -C config/puma.rb