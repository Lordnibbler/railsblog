# Dockerfile

ARG RUBY_VERSION=3.3.8
FROM ruby:${RUBY_VERSION}

# 1) System deps + Node.js 22.x via NodeSource
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
      curl \
      gnupg \
      build-essential \
      postgresql-client \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# 2) Install exactly Yarn 1.22.19
RUN npm install -g yarn@1.22.19

WORKDIR /app

# 3) Copy and install gems
COPY Gemfile Gemfile.lock ./

# Allow build-time selection of RAILS_ENV (default is development)
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

# Only skip dev/test gems in production builds
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle config set without 'development test'; \
    fi \
 && bundle install --jobs=4

# 4) Copy & install JS dependencies
COPY package.json yarn.lock ./
RUN yarn install

# 5) Copy the rest of the app
COPY . .

# 6) Precompile assets if this is a production build
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle exec rake assets:precompile; \
    fi

# Ensure Rails serves static files (needed on Heroku)
ENV RAILS_SERVE_STATIC_FILES=true

EXPOSE 3000

# 7) Default command: run Puma with your config
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]