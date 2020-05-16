# send emails from contact page in the background
class ContactFormWorker
  include Sidekiq::Worker

  def perform(params)
    @params = params
    return unless contact_form.valid?
    contact_form.deliver
  end

  private

  attr_reader :params

  def contact_form
    @contact_form ||= ContactForm.new(params)
  end
end
