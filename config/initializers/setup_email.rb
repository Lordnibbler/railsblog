ActionMailer::Base.default_url_options = { host: ENV['RAILS_HOST'], port: ENV['RAILS_PORT'] }
ActionMailer::Base.smtp_settings = {
    address: 'smtp.mailgun.org',
    port: ENV['MAILGUN_SMTP_PORT'] || 587,
    domain: ENV['MAILGUN_DOMAIN'],
    authentication: 'plain',
    user_name: ENV['MAILGUN_SMTP_LOGIN'],
    password: ENV['MAILGUN_SMTP_PASSWORD'],
    enable_starttls_auto: true
}
