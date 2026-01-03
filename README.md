# benradler.com
This is a Ruby on Rails 8 app. It does the following:
* displays a portfolio homepage with personal information and work history - [link](https://benradler.com)
* offers a contact form - [link](https://benradler.com/#contact)
* offers a newsletter signup form
* renders Markdown-formatted blog posts as HTML - [link](https://benradler.com/blog)
* fetches a Flickr.com feed of my photos and renders them using photoswipe.js - [link](https://benradler.com/photography)

## Development

Follow these instructions to get the app running locally.

### Start Everything with docker-compose

```shell
# start everything
docker-compose up

# start everything, detached from terminal
docker-compose up -d

# only build the docker containers
docker-compose build
```

### Start Postgres with docker-compose

This automatically restores the raw sql dump from `db/init/heroku_dump.sql` onto the database on first start.

```shell
# start db container inside docker
$ docker-compose up -d db

# or if the container is already created
$ docker-compose start db

# this will stop & remove the container but leave the db data volume intact.
$ docker-compose down

# this will stop & remove the container AND remove any volumes declared in docker-compose.yml,
# effectively destroying the db
$ docker-compose down -v
```

If you wish to generate an updated heroku sql dump:

```shell
# get the database url
$ $DB_URL=`heroku config:get DATABASE_URL --app benradler`

# create a dump file and copy it to pwd
$ docker run --rm \
  -v "$(pwd)":/backups \
  postgres:17.4 \
  pg_dump \
    --no-owner \
    --no-acl \
    --format=plain \
    --file=/backups/heroku_dump.sql \
    "$DB_URL"
```

### Run commands inside docker containers

```shell
# run the rails console
docker-compose exec web rails c

# run unit tests (this won't work since docker runs in production env, so test gem group is missing)
docker-compose exec web rspec
```

### Start rails server and asset bundlers without docker

```shell
# install dependencies
brew bundle

# create a YAML file to stub environment variables
$ mv config/env.yml.example config/env.yml
$ vi config/env.yml

# install dependencies
$ bundle
$ yarn

#
# ONE SHOT COMMAND
#
$ ./bin/dev

#
# START EVERYTHING INDIVIDUALLY
#

# start the rails web server
$ rails s

# watch JS bundles with esbuild
$ yarn build:js:watch

# watch CSS bundles
$ yarn build:css:watch

# start the guard watcher for tests and code formatting
$ guard

# open the browser
$ open "http://localhost:3000"
```

## Deployment

This app is deployed to heroku via a docker container, using the `container` stack.

No Procfile needed due to [`heroku.yml`](https://www.heroku.com/blog/build-docker-images-heroku-yml/). Heroku will honor this manifest instead. On each `container:release`, Heroku will run [`entrypoint.sh`](./entrypoint.sh):

1. Pull the web image you just pushed.
2. Run bundle exec rails db:migrate.
3. Run bundle exec rails cache_warmer:flickr.
4. Start web dyno with bundle exec puma -C config/puma.rb.

### Automatic Deployments

Automatic deployments are configured in CircleCI. If the `build` and `test` steps are green, and the branch is `master`, the `deploy` step begins. It uses the same heroku container registry deployment approach, but the docker container is built via docker directly and pushed to Heroku registry explicitly.

The authentication is handled via a 1 year long lived token which was generated via

```shell
heroku authorizations:create
```

and set at <https://app.circleci.com/settings/project/github/Lordnibbler/railsblog/environment-variables>.

### Manual Deployments to Heroku via containers

```shell
# authenticate
heroku login
heroku container:login

# creates the container and pushes it to the heroku registry
heroku container:push web -a benradler

# NOTE: you can override env vars if needed like so:
heroku container:push web --arg RAILS_ENV=production -a benradler

# releases this particular container onto the server
heroku container:release web -a benradler

# or all in one command:
heroku login && heroku container:login && heroku container:push web -a benradler && heroku container:release web -a benradler
```

### Debugging

List recent release via:

```shell
heroku releases -a benradler
```

See any output from some release:

```shell
heroku releases:output <replace with release version>
```

Tail release logs:

```shell
heroku logs --tail --dyno release --app benradler
```

## Architecture
This is a Rails app, deployed on Heroku.

### Persistence

#### postgresql
It uses Heroku Postgresql, configured via `DATABASE_URL` env var. The schema can be found in [db/schema.rb](db/schema.rb).

#### redis
It uses redis-to-go, configured via `REDISCLOUD_URL` env var. Redis backs the cache for the photography gallery.

### Cron
It uses Heroku Scheduler add on to run two recurring jobs:

* `rails sitemap:refresh`
  * runs daily to refresh the sitemap file for the site
* `rails cache_warmer:flickr`
  * runs daily to fetch all Flickr photos for the photography page and write their metadata to redit. this job also shuffles the images so their order changes daily to keep the page looking fresh.
  * photo cache itself expires after 3 days, and a single warm cache key expires after 1 day. as a result, back to back deploys do not trigger a re-warm of the cache, and if a scheduler job fails to run we won't be likely to be left without a cache since there are 2 more attempts in the next 48h.


### CDN

#### Cloudflare
Cloudflare is used for DDoS protection, a basic cache, and CDN.

**NOTE**: Caching of .mp4 files is explicitly disabled in a custom page rule due to issues with Cloudflare changing HTTP 206 to 200, and causing Safari to not load .mp4 files. See [this issue in Cloudflare forums](https://community.cloudflare.com/t/mp4-wont-load-in-safari-using-cloudflare/10587/45) for more information.


#### Cloudfront
AWS Cloudfront creates a CDN distribution mirroring the website. The rails `ASSET_HOST` env var is set to cause asset helper functions to use the Cloudfront host instead of the main domain.


### Images
Images are stored on AWS S3 by way of ActiveStorage in Rails. There are [custom CDN routes defined](https://github.com/Lordnibbler/railsblog/blob/51c77571d72969f41760d5d00d511e4cc9de27c6/config/routes.rb#L72-L95), which allow for use of url helpers such as `cdn_image_url`.


### Email
Mailgun is used to send emails from the contact forms.

### HTTPS
Cloudflare provides HTTPS via Let's Encrypt. The Rails application layer is [configured to force an SSL connection](https://github.com/Lordnibbler/railsblog/blob/51c77571d72969f41760d5d00d511e4cc9de27c6/config/environments/production.rb#L52).

### Frontend
The frontend of the site is built using esbuild (via jsbundling-rails and propshaft).

The technologies used are:
* [turbo](https://turbo.hotwired.dev/)
  * for only loading portions of the page that change when browsing around the site
  * **NOTE** this is disabled for anchor links on the homepage as it causes breaking behavior. [more info here](https://github.com/Lordnibbler/railsblog/pull/130)
* [tailwindcss](https://tailwindcss.com)
  * for presentation of the site
* [alpine.js](https://alpinejs.dev/) and [alpine-magic-helpers](https://github.com/alpine-collective/alpine-magic-helpers)
  * for mobile navigation menu
* [boxicons](https://boxicons.com/)
  * for scalable vector graphic icons
* [marked.js](https://marked.js.org/)
  * for markdown to HTML rendering
* [photoswipe.js](https://photoswipe.com/)
  * for the beautiful gallery in the photography page
* [masonry.js](https://masonry.desandro.com/)
  * for keeping photos aligned in a clean grid in the photography page
* [infinite scroll](https://infinite-scroll.com/)
  * for loading batches of photos when scrolling in the photography page

### Testing
* [rspsec](https://rspec.info/) is used for [unit testing](spec/)
* [factorybot](https://github.com/thoughtbot/factory_bot) is used to make reusable [test objects](spec/factories)
* [VCR](https://github.com/vcr/vcr) is used for recording/playing back HTTP requests and responses in lieu of mocking
* [capybara](https://github.com/teamcapybara/capybara) + headless chrome ([webdrivers](https://github.com/titusfortner/webdrivers)) is used for [feature testing](spec/features)

### Static Code Analysis
* [guard](https://github.com/guard/guard) is used to automatically run unit tests and static code analysis tools during development
* [rubocop](https://github.com/rubocop/rubocop) is used to [enforce code style](.rubocop.yml)
* [brakeman](https://brakemanscanner.org/) is used to check for common security vulnerabilities

### Observability

#### NewRelic
For observing performance data about the rails application.

#### LogDNA
For observing stderr and stdout logs emitted by the rails application.
