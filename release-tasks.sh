#!/usr/bin/env bash
set -e

echo "---- Release phase starting via release_tasks.sh ----"
bundle exec rails db:migrate && echo "db:migrate finished"
bundle exec rails cache_warmer:flickr && echo "cache_warmer done"
echo "---- Release phase complete ----"