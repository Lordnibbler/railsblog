#
# endpoint to sign up for newsletter
#
class NewsletterSignupsController < ApplicationController
    def create
        newsletter = NewsletterSignup.create(newsletter_signup_params)

        # TODO: handle case where you're already signed up for newsletter and show flash[:warning]

        if newsletter.errors.any?
            flash[:error] = "Failed to join newsletter. #{newsletter.errors.full_messages.join(', ')}"
        else
            flash[:success] = 'Thanks for joining my newsletter!'
        end
        
        redirect_to root_path
    end

    private
    
    def newsletter_signup_params
        params.require(:newsletter_signup).permit(:email)
    end
  end
  