class NewsletterSignupMailer < ApplicationMailer
  def confirmation(email, url_options = {})
    @confirmation_url = confirm_newsletter_signups_url(**url_options, token: confirmation_token(email))
    mail(to: email, subject: 'Confirm your newsletter subscription')
  end

  private

  def confirmation_token(email)
    Rails.application.message_verifier(:newsletter_signup).generate(
      email,
      expires_in: 24.hours,
      purpose: :newsletter_signup
    )
  end
end
