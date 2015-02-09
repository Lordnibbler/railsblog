class ContactFormsController < ApplicationController
  def create
    contact_form = ContactForm.new(params[:contact_form])
    contact_form.request = request # append remote ip, user agent and session

    if contact_form.deliver
      flash[:notice] = 'Email sent successfully'
    else
      flash[:error] = 'Email failed to send'
    end

    redirect_to page_path(:contact_me)
  end
end
