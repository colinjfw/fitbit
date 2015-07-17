class Oauth2CallbacksController < ApplicationController
  def fitbit
    split = Base64.strict_decode64(params[:state]).split(':') ; csrf = split[0] ; email = split[1]
    fitbit_user = Oauth2Rails::Auth.new.get_token(params[:code])
    user = User.find_by(email: email)
    if user.csrf_token == BCrypt::Password.new(csrf)
      user.update!(
        refresh_token:  fitbit_user.refresh_token,
        access_token:   fitbit_user.access_token,
        expiry:         DateTime.now + (fitbit_user.expires_every.to_i - 20).seconds
      )
      log_in(user)
      redirect_to user_path(user)
    else
      flash[:danger] = "We've intercepted an attack, your data is safe."
      redirect_to root_path
    end
  end
end
