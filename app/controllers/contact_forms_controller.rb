#
# endpoints to submit a contact-me <form> for validation and email delivery
#
class ContactFormsController < ApplicationController
  before_action do
    set_body_class('contact')
  end

  def create
    if deliver_contact_form!
      flash[:success] = 'Email sent successfully'
    else
      flash[:error] = 'Email failed to send'
    end

    # redirect to homepage if submitting contact form from homepage
    redirect_path = params[:request_route] == root_path ? root_path : page_path('contact-me')
    redirect_to redirect_path
  end

  private

  def deliver_contact_form!
    contact_form.deliver
  end

  def contact_form
    @contact_form ||= ContactForm.new(params[:contact_form].merge(request: request))
  end
end
