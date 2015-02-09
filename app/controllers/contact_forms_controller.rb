class ContactFormsController < ApplicationController
  def create
    if ContactForm.new(params[:contact_form].merge(request: request)).deliver
      flash[:success] = 'Email sent successfully'
    else
      flash[:error] = 'Email failed to send'
    end
    redirect_to page_path(:contact_me)
  end
end
