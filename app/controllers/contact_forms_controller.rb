#
# endpoints to submit a contact-me <form> for validation and email delivery
#
class ContactFormsController < ApplicationController
  def create
    sent = ContactForm.new(params[:contact_form].merge(request: request)).deliver
    sent ? flash[:success] = 'Email sent successfully' : flash[:error] = 'Email failed to send'
    redirect_to page_path('contact-me')
  end
end
