#!/usr/bin/env bash
set -e

echo "---- Release phase starting via release_tasks.sh ----"
bundle exec rails db:migrate && echo "db:migrate finished"

if bundle exec rails runner 'exit(FlickrService.cache_warmed? ? 0 : 1)'; then
  echo "flickr cache already warm"
else
  # Warm opportunistically so slow Flickr responses cannot block Puma startup.
  (
    timeout "${CACHE_WARMER_BOOT_TIMEOUT:-45s}" bundle exec rails cache_warmer:flickr \
      && echo "cache_warmer done" \
      || echo "cache_warmer skipped or timed out"
  ) &
fi

echo "---- Release phase complete ----"
