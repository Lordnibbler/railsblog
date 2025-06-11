ARG RUBY_VERSION=3.4.4
FROM ruby:${RUBY_VERSION}

# 1) System deps + Node.js 22.x via NodeSource
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
      curl gnupg build-essential postgresql-client \
      chromium chromium-driver \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# 2) Exact Yarn version
RUN npm install -g yarn@1.22.19

WORKDIR /app

# 3) By default build for PRODUCTION — override at build-time with
#    `--build-arg RAILS_ENV=development` if you want local-dev.
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ENV RAILS_SERVE_STATIC_FILES=true
# tell Webdrivers / Selenium where to find Chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV WEB_DRIVER_CHROME_DRIVER=/usr/bin/chromedriver

# allow setting secret key base
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# 4) Ensure Rails will serve compiled assets
ENV RAILS_SERVE_STATIC_FILES=true

# 5) Install gems (skip dev/test in prod)
COPY Gemfile Gemfile.lock ./
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle config set without 'development test'; \
    fi \
 && bundle install --jobs=4

# 6) Install JS dependencies (including devDeps for webpack)
COPY package.json yarn.lock ./
ENV YARN_PRODUCTION=false
RUN yarn install --frozen-lockfile

# 7) Copy the rest of your app
COPY . .

# 8) Compile your JS/CSS packs (only runs if RAILS_ENV=production)
RUN if [ "$RAILS_ENV" = "production" ]; then \
      # if no build-arg was passed, generate a one-off secret for this build
      if [ -z "$SECRET_KEY_BASE" ]; then \
        echo ">>> Generating temporary SECRET_KEY_BASE for assets precompile" && \
        export SECRET_KEY_BASE="$(bundle exec rails secret)"; \
      fi && \
      # now that ENV is set, compile assets
      bundle exec rails assets:precompile; \
    fi
# 9) Copy in the entrypoint and release scripts (to migrate db, warm cache, start puma server)
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
COPY release-tasks.sh /usr/bin/release-tasks.sh
RUN chmod +x /usr/bin/release-tasks.sh
EXPOSE 3000

# 10) run it
# you can even leave CMD empty or set it to ["bundle","exec","puma",...]
ENTRYPOINT ["entrypoint.sh"]
CMD []
