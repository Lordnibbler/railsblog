# benradler.com
This is a Ruby on Rails 6.1 app. It does the following:
* displays a portfolio homepage with personal information and work history - [link](https://benradler.com)
* offers a contact form
* offers a newsletter signup form
* renders Markdown-formatted blog posts as HTML - [link](https://benradler.com/blog)
* fetches a Flickr.com feed of my photos and renders them using photoswipe.js - [link](https://benradler.com/photography)

## Development

```sh
# create a YAML file to stub environment variables
$ mv config/env.yml.example config/env.yml
$ vi config/env.yml

# set up database
$ rails db:setup

# install dependencies
$ bundle
$ yarn

# start the rails web server
$ rails s

# start the webpack dev server
$ ./bin/webpack-dev-server

# start the guard watcher for tests and code formatting
$ guard
```

## Architecture
This is a Rails app, deployed on Heroku.


### Persistence

#### postgresql
It uses Heroku Postgresql, configured via `DATABASE_URL` env var. The schema can be found in [db/schema.rb](db/schema.rb).

#### redis
It uses redis-to-go, configured via `REDISCLOUD_URL` env var.

### Cron
It uses Heroku Scheduler add on to run two recurring jobs:

* `rails sitemap:refresh`
  * runs daily to refresh the sitemap file for the site
* `rails cache_warmer:flickr`
  * runs daily to fetch all Flickr photos for the photography page and write their metadata to redit. this job also shuffles the images so their order changes daily to keep the page looking fresh.
  * photo cache itself expires after 3 days, and a single warm cache key expires after 1 day. as a result, back to back deploys do not trigger a re-warm of the cache, and if a scheduler job fails to run we won't be likely to be left without a cache since there are 2 more attempts in the next 48h.


### CDN

#### Cloudflare
Cloudflare is used for DDoS protection and a basic cache and CDN.


**NOTE**: Caching of .mp4 files is explicitly disabled in a custom page rule due to issues with Cloudflare changing HTTP 206 to 200, and causing Safari to not load .mp4 files.


#### Cloudfront
AWS Cloudfront creates a distribution mirroring the website. The rails `ASSET_HOST` env var is set to cause asset helper functions to use the Cloudfront host instead of the main domain.


### Images
Images are stored on AWS S3 by way of ActiveStorage in Rails. There are [custom CDN routes defined](https://github.com/Lordnibbler/railsblog/blob/51c77571d72969f41760d5d00d511e4cc9de27c6/config/routes.rb#L72-L95), which allow for use of url helpers such as `cdn_image_url`.


### Email

Sendgrid is used to send emails from the contact forms.

### HTTPS

Cloudflare provides HTTPS via Let's Encrypt. The Rails application layer is [configured to force an SSL connection](https://github.com/Lordnibbler/railsblog/blob/51c77571d72969f41760d5d00d511e4cc9de27c6/config/environments/production.rb#L52).

### Frontend

The frontend of the site is built using Webpacker.

The technologies used are:
* tailwindcss
  * for presentation of the site
* alpine.js and alpine-magic-helpers
  * for mobile navigation menu
* marked
  * for markdown to HTML rendering
* photoswipe.js
  * for photography page