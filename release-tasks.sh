#!/usr/bin/env bash
set -e

echo "---- Release phase starting via release_tasks.sh ----"
bundle exec rails db:migrate && echo "db:migrate finished"
echo "---- Release phase complete ----"
