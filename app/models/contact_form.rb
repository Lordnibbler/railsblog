#
# Represents the message to be emailed from the contact-me <form>
#
class ContactForm < MailForm::Base
  attribute :name,     validate: true
  attribute :email,    validate: /\A[^@\s]+@[^@\s]+\z/i
  attribute :message,  validate: true
  attribute :nickname, captcha: true
  append :remote_ip, :user_agent, :session

  validates :nickname, absence: true

  # Declare the e-mail headers. It accepts anything the mail method in ActionMailer accepts.
  def headers
    {
      subject: "Contact Form from #{name} at benradler.com",
      to: 'ben@benradler.com',
      from: 'ben@benradler.com',
      reply_to: %("#{name}" <#{email}>),
    }
  end
end
