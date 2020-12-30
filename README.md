# benradler.com rails blog
This is a rails 6.1 app. It does the following:
* offers a static homepage
* renders Markdown-formatted blog posts as HTML
* fetches a Flickr.com feed of my photos and renders them using photoswipe.js
* offers a contact form

## Getting Started

```sh
# bundle the application
bundle

# create a YAML file to stub environment variables
mv config/env.yml.example config/env.yml
vi config/env.yml
```
