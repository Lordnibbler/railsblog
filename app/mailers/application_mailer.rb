# Base mailer containing defaults shared by all application emails.
class ApplicationMailer < ActionMailer::Base
  default from: 'ben@benradler.com'
  layout 'mailer'
end
