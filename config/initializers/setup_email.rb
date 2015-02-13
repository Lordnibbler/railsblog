ActionMailer::Base.default_url_options = { host: ENV['RAILS_HOST'], port: ENV['RAILS_PORT'] }
ActionMailer::Base.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: ENV['SENDGRID_SMTP_PORT'],
    domain: ENV['SENDGRID_SMTP_SERVER'],
    authentication: 'plain',
    user_name: ENV['SENDGRID_SMTP_LOGIN'],
    password: ENV['SENDGRID_SMTP_PASSWORD'],
    enable_starttls_autotrue: true
}
