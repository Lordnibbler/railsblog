#
# endpoints to submit a contact-me <form> for validation and email delivery
#
class ContactFormsController < ApplicationController
  def create
    deliver_contact_form!
    flash[:success] = 'Email sent successfully'
    redirect_to page_path('contact-me')
  end

  private

  def deliver_contact_form!
    ContactFormWorker.perform_async(contact_form_params)
  end

  def contact_form_params
    params[:contact_form].merge(request: request)
  end
end
