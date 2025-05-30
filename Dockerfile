# Dockerfile

ARG RUBY_VERSION=3.3.8
FROM ruby:${RUBY_VERSION}

# 1) System deps + Node.js 22.x via NodeSource
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
      curl gnupg build-essential postgresql-client \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# 2) Exact Yarn version
RUN npm install -g yarn@1.22.19

WORKDIR /app

#
# 3) By default build for PRODUCTION — override at build-time with
#    `--build-arg RAILS_ENV=development` if you want local-dev.
#
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

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
      bundle exec rake assets:precompile; \
    fi

EXPOSE 3000

# 9) Launch Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]