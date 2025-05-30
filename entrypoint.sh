#!/usr/bin/env bash
set -e

if [ "$RELEASE_PHASE" = "true" ]; then
  echo "---- Release phase starting ----"
  bundle exec rails db:migrate && echo "db:migrate finished"
  bundle exec rails cache_warmer:flickr && echo "cache_warmer done"
  echo "---- Release phase complete ----"
  exit 0
fi

# otherwise fall‐through to the normal web server
exec bundle exec puma -C config/puma.rb