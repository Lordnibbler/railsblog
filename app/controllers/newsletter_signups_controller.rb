#
# endpoint to sign up for newsletter
#
class NewsletterSignupsController < ApplicationController
  def create
    return redirect_to(root_path) if newsletter_signup_params[:website].present?

    newsletter = NewsletterSignup.new(email: newsletter_signup_params[:email])

    if newsletter.invalid?
      flash[:error] = "Failed to join newsletter. #{newsletter.errors.full_messages.join(', ')}"
    else
      NewsletterSignupMailer.confirmation(newsletter.email).deliver_now unless NewsletterSignup.exists?(email: newsletter.email)
      flash[:success] = 'Check your email to confirm your newsletter subscription.'
    end

    redirect_to root_path
  end

  def confirm
    email = Rails.application.message_verifier(:newsletter_signup).verify(params[:token], purpose: :newsletter_signup)
    NewsletterSignup.find_or_create_by!(email: email)
    flash[:success] = 'Thanks for joining my newsletter! Your email has been confirmed.'
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    flash[:error] = 'That confirmation link is invalid or has expired. Please sign up again.'
  rescue ActiveRecord::RecordNotUnique
    flash[:success] = 'Thanks for joining my newsletter! Your email has been confirmed.'
  ensure
    redirect_to root_path
  end

  private

  def newsletter_signup_params
    params.expect(newsletter_signup: [:email, :website])
  end
end
