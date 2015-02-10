class ContactForm < MailForm::Base
  attribute :name,     validate: true
  attribute :email,    validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message,  validate: true
  attribute :nickname, captcha: true
  append :remote_ip, :user_agent, :session

  # Declare the e-mail headers. It accepts anything the mail method in ActionMailer accepts.
  def headers
    {
      subject: "Contact Form from #{name} at benradler.com",
      to:      'benradler@me.com',
      from:    %("#{name}" <#{email}>)
    }
  end
end
