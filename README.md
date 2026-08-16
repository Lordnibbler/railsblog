# benradler.com
This is a Ruby on Rails 8 app. It does the following:
* displays a portfolio homepage with personal information and work history - [link](https://benradler.com)
* offers a contact form - [link](https://benradler.com/#contact)
* offers a newsletter signup form
* renders Markdown-formatted blog posts as HTML - [link](https://benradler.com/blog)
* synchronizes Flickr photo metadata into PostgreSQL and renders the gallery using photoswipe.js - [link](https://benradler.com/photography)

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

# run unit tests (set RAILS_ENV=test)
docker-compose exec -e RAILS_ENV=test web bundle exec rspec

# JS feature specs will precompile assets once automatically
```

### Start rails server and asset bundlers without docker

Setup (one time)

```shell
# install dependencies
brew bundle

# create a YAML file to stub environment variables
mv config/env.yml.example config/env.yml
vi config/env.yml

# install dependencies
bundle
yarn
```

One-shot command to start everything

```shell
./bin/dev
```

`bin/dev` clears generated precompiled assets before starting Rails and the JS/CSS
watchers. After changing frontend source files, wait for the relevant watcher to
finish and refresh the browser; the development processes do not need restarting.

Start everything individually

```shell
# start the rails web server
rails s

# watch JS bundles with esbuild
yarn build:js:watch

# watch CSS bundles
yarn build:css:watch

# start the guard watcher for tests and code formatting
guard
```

Open the browser

```shell
open "http://localhost:3000"
```

## Deployment

This app is deployed to heroku via a docker container, using the `container` stack.

No Procfile needed due to [`heroku.yml`](https://www.heroku.com/blog/build-docker-images-heroku-yml/). Heroku will honor this manifest instead. On each `container:release`:

1. Pull the web image you just pushed.
2. Run the release phase command, [`release-tasks.sh`](./release-tasks.sh), which runs `bundle exec rails db:migrate`.
3. Start the web dyno with [`entrypoint.sh`](./entrypoint.sh), which runs [`release-tasks.sh`](./release-tasks.sh) in production and then starts `bundle exec puma -C config/puma.rb`.

The Flickr synchronization is intentionally not part of web dyno startup. It runs via Heroku Scheduler so a slow Flickr response cannot make a freshly deployed web dyno return errors while it is coming up. Web requests read only from PostgreSQL and never call Flickr directly.

### Automatic Deployments

Automatic deployments are configured in CircleCI. If the `build` and `test` steps are green, and the branch is `master`, the `deploy` step begins. It uses the same heroku container registry deployment approach, but the docker container is built via docker directly and pushed to Heroku registry explicitly.

The authentication is handled via a 1 year long lived token which was generated via

```shell
heroku authorizations:create
```

and set at <https://app.circleci.com/settings/project/github/Lordnibbler/railsblog/environment-variables>.

### Lab operations telemetry

The Site Control Room works without provider credentials, but its New Relic and CircleCI panels need read-only server-side API credentials for live production data. Configure them as Heroku config vars; they are consumed by Rails and are never sent to the browser:

```shell
heroku config:set \
  NEW_RELIC_LICENSE_KEY=your_ingest_license_key \
  NEW_RELIC_USER_API_KEY=your_user_api_key \
  NEW_RELIC_ACCOUNT_ID=your_numeric_account_id \
  NEW_RELIC_APP_NAME=benradler.com \
  CIRCLECI_TOKEN=your_circleci_personal_api_token \
  CIRCLECI_BRANCH=master \
  --app benradler
```

`NEW_RELIC_LICENSE_KEY` activates the installed Ruby APM agent. The user API key and account ID let the control-room endpoint query NerdGraph for the last 30 minutes of response time, throughput, and errors. `NEW_RELIC_APP_NAME` must match the application name reported by `config/newrelic.yml`. `CIRCLECI_TOKEN` must be able to read project insights; the panel queries the `build_test_deploy` workflow for the configured branch.

Create or retrieve the New Relic ingest license and user keys from the New Relic API Keys screen. The numeric account ID is the value shown by the account selector or the `account` query parameter in a New Relic URL. For example, `account=898521` means `NEW_RELIC_ACCOUNT_ID=898521`. A UUID shown beneath a user or access-management identity is not the account ID. The user key must belong to a user who can query the selected account through NerdGraph.

CircleCI API v2 requires a personal API token. Create one under **User Settings → Personal API Tokens**, test it against `https://circleci.com/api/v2/me`, and store it on Heroku as `CIRCLECI_TOKEN`. Do not configure this particular token only as a CircleCI project environment variable: the production Rails process makes the Insights request, so the credential must be available to the Heroku app.

Once those config vars are present and a new dyno is running, both panels load automatically in production. They can be verified without exposing their credentials:

```shell
curl -s https://benradler.com/api/v1/operations

heroku config:get NEW_RELIC_APP_NAME --app benradler
heroku config:get NEW_RELIC_ACCOUNT_ID --app benradler
heroku config:get CIRCLECI_BRANCH --app benradler
```

The JSON response should report `connected: true` for both providers. New Relic metrics can initially be zero until the APM application has received traffic within the queried 30-minute window.

Enable Heroku runtime dyno metadata so the “Since deploy” clock and current release timestamp receive `HEROKU_RELEASE_CREATED_AT`, `HEROKU_RELEASE_VERSION`, and build metadata:

```shell
heroku labs:enable runtime-dyno-metadata --app benradler
heroku labs:enable runtime-dyno-build-metadata --app benradler
```

Heroku makes this metadata available on the next deployment. A restart alone might not populate it, so deploy a new release after enabling both Labs features. Do not manually set `HEROKU_*` variables.

The control room intentionally displays “metadata unavailable” during local development because a local process has no Heroku release. If production still shows that message after a new deployment, inspect the release metadata from a one-off dyno:

```shell
heroku run 'printenv HEROKU_RELEASE_CREATED_AT' --app benradler
heroku run 'printenv HEROKU_RELEASE_VERSION' --app benradler

heroku labs:info runtime-dyno-metadata --app benradler
heroku labs:info runtime-dyno-build-metadata --app benradler
```

`HEROKU_RELEASE_CREATED_AT` should return an ISO-8601 timestamp. If it is empty, confirm both Labs features are enabled and perform another deployment.

Recent deployment rows come from successful runs of CircleCI’s `build_test_deploy` workflow on the configured production branch. The panel shows the completion date and time, duration, branch, credits used, and CircleCI workflow ID. Because the deploy job is filtered to `master`, a successful workflow returned for that branch represents a successful production deployment. Current Heroku release metadata appears independently.

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

# Production all in one command:
heroku login && heroku container:login && heroku container:push web -a benradler && heroku container:release web -a benradler

# Staging all in one command:
heroku login && heroku container:login && heroku container:push web -a benradler-staging && heroku container:release web -a benradler-staging
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
It uses Heroku Postgresql, configured via `DATABASE_URL` env var. In addition to application records, PostgreSQL stores the normalized Flickr photo catalog, its current display order, and cached vision-model composition readings used by the Composition Studio. The schema can be found in [db/schema.rb](db/schema.rb).

### Cron
It uses Heroku Scheduler add on to run two recurring jobs:

* `rails sitemap:refresh`
  * runs daily to refresh the sitemap file for the site
* `rails flickr:sync`
  * runs daily to fetch all Flickr photos and atomically synchronize their metadata into PostgreSQL.
  * analyzes up to 20 photographs only when they have no stored composition analysis and `OPENAI_API_KEY` is configured. Existing paid results are retained even when the analysis version changes. Set `COMPOSITION_ANALYSIS_LIMIT` to tune that batch size and `OPENAI_COMPOSITION_MODEL` to override the default `gpt-5-mini` model.
  * each successful run assigns a new shuffled display order, which remains stable across paginated requests until the next run.
  * Flickr is fully fetched before the database transaction begins, so existing photos remain available if Flickr is unavailable or the fetch fails.
  * run this task once after the migration is first deployed to populate the initially empty `flickr_photos` table; subsequent refreshes are handled by Heroku Scheduler.

Run `rails flickr:analyze_compositions` to analyze the next pending batch without synchronizing Flickr. The API key is used only by this server-side task; model results and normalized overlay coordinates are saved in PostgreSQL, so page requests never call OpenAI or expose credentials.

To intentionally replace existing paid results, pass the explicit `force` argument to either task: `rails 'flickr:sync[force]'` or `rails 'flickr:analyze_compositions[force]'`. The configured batch limit still applies.

Move paid composition readings between databases without calling the model again:

```shell
# Export from the source database. The JSON includes a record count and SHA-256 checksum.
rails flickr:export_composition_analyses > /tmp/composition-analyses.json

# Import after the destination has the Flickr catalog and composition migration.
FILE=/tmp/composition-analyses.json rails flickr:import_composition_analyses
```

The importer matches rows by Flickr ID, rejects missing or duplicate IDs and modified payloads, and updates only composition-analysis columns in a transaction. It never invokes OpenAI.

Each persisted reading is bound to its Flickr ID and current analysis version. Its classifications receive image-scoped IDs and contain photograph-specific evidence plus normalized overlay geometry. The rubric currently covers twenty-four techniques, including perspective, abstraction, motion blur, light and shadow, silhouette, reflection, scale, occlusion, asymmetrical balance, and low/high camera angles. Existing stored readings are preserved when the rubric changes; they are only replaced by an explicit forced analysis run.


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
