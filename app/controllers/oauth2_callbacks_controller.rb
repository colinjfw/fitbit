class Oauth2CallbacksController < ApplicationController
  def fitbit
    split = Base64.decode64(params[:state]).split(':') ; csrf = split[0] ; id = split[1].to_i
    user = User.find(id)
    if user.csrf_token == BCrypt::Password.new(csrf)
      fitbit_user = Oauth2Rails::Auth.new.get_token(params[:code])
      user.update!(
        refresh_token:  fitbit_user.refresh_token,
        access_token:   fitbit_user.access_token,
        expiry:         DateTime.now + (fitbit_user.expires_every.to_i - 20).seconds
      )
      log_in(user)
      redirect_to user_path(user)
    else
      flash[:danger] = "We've intercepted an attack, don't worry your data is safe."
      redirect_to root_path
    end
  end
end
