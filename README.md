# benradler.com rails blog
This is a rails 6.1 app. It does the following:
* offers a static homepage
* renders Markdown-formatted blog posts as HTML
* fetches a Flickr.com feed of my photos and renders them using photoswipe.js
* offers a contact form

## Getting Started

```sh
# create a YAML file to stub environment variables
$ mv config/env.yml.example config/env.yml
$ vi config/env.yml

# set up database
$ rails db:setup

# install dependencies
$ bundle
$ yarn

# start the app
$ rails s
$ ./bin/webpack-dev-server
```
