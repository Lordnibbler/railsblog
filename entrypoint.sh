#!/usr/bin/env bash
set -e

# if we were passed any arguments, just run them
if [ $# -gt 0 ]; then
  exec "$@"
fi

# start web server
exec bundle exec puma -C config/puma.rb
