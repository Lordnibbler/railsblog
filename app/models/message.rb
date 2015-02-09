class Message
  include ActiveModel::Model
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :name, :email, :message

  validates             :name,    presence: true, length: { maximum: 100 }
  validates_presence_of :email
  validates_format_of   :email,   with: /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i, message: "invalid email"
  validates             :message, presence: true, length: { minimum: 1 }

  #
  # instantiate setting each attr_accessor via the passed in attributes
  #
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  #
  # @return [Hash] all attr_accessors of the message
  #
  def attributes
    Hash[
      instance_variables
        .reject { |name| %i(@validation_context @errors).include?(name) }
        .map { |name| [name.to_s[1..-1], instance_variable_get(name)] }
    ]
  end

  #
  # don't persist to database
  #
  def persisted?
    false
  end

  #
  # public API to send an email using sendgrid
  # @return [Boolean] did the email send successfully
  #
  def send_email
    !!(sendgrid_client.send(mail) =~ /success/)
  end

  private

  #
  # @return [SendGrid::Client] client built using SENDGRID ENV vars
  #
  def sendgrid_client
    @sendgrid_client ||= SendGrid::Client.new(
      api_user: ENV['SENDGRID_SMTP_LOGIN'],
      api_key:  ENV['SENDGRID_SMTP_PASSWORD']
    )
  end

  #
  # @return [SendGrid::Mail] mail object prepared from this message instance's attr_accessors
  #
  def mail
    SendGrid::Mail.new do |m|
      m.to        = 'benradler@me.com'
      m.from_name = @name
      m.from      = @email
      m.subject   = "Contact Form from #{@name} at benradler.com"
      m.text      = @message
    end
  end
end
