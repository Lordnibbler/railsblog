web:     bundle exec puma -C config/puma.rb
release: bash -lc "\
  echo '---- Release phase starting ----'; \
  bundle exec rails db:migrate && echo 'db:migrate finished'; \
  bundle exec rails cache_warmer:flickr && echo 'cache_warmer:flickr finished'; \
  echo '---- Release phase complete ----'\
"