#
# endpoints to submit a contact-me <form> for validation and email delivery
#
class ContactFormsController < ApplicationController
  def create
    if deliver_contact_form!
      flash[:success] = 'Email sent successfully'
    else
      flash[:error] = 'Email failed to send'
    end
    redirect_to page_path('contact-me')
  end

  private

  def deliver_contact_form!
    contact_form.deliver
  end

  def contact_form
    @contact_form ||= ContactForm.new(params[:contact_form].merge(request: request))
  end
end
