class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # εδώ παίρνουμε τα στοιχεία από Google και κάνουμε login
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      redirect_to new_user_session_path, alert: "Δεν ολοκληρώθηκε το login με Google."
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Κάτι πήγε στραβά με τη σύνδεση Google."
  end
end
