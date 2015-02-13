# benradler.com rails blog
This is a rails 4.2 blogging application that parses `.md` files into blog posts.

## Getting Started

```sh
# bundle the application
bundle

# create a YAML file to stub environment variables
vi config/local_env.yml
```

The contents of `local_env.yml` should look like this:

```yaml
development:
  RAILS_HOST: 'http://localhost'
  RAILS_PORT: '3000'
  SENDGRID_SMTP_PORT: '587'
  SENDGRID_SMTP_SERVER: "whatever.com"
  SENDGRID_SMTP_LOGIN: "me"
  SENDGRID_SMTP_PASSWORD: "super-secret"

test:
  RAILS_HOST: 'http://localhost'
  RAILS_PORT: '3000'
  SENDGRID_SMTP_PORT: '587'
  SENDGRID_SMTP_SERVER: "whatever.com"
  SENDGRID_SMTP_LOGIN: "me"
  SENDGRID_SMTP_PASSWORD: "super-secret"
```
