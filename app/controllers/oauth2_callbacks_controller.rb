class Oauth2CallbacksController < ApplicationController
  def fitbit
    fitbit_user = Oauth2Rails::Auth.new.get_token(params[:code])
    user = User.find_by(email: params[:state])
    user.update!(
      refresh_token:  fitbit_user.refresh_token,
      access_token:   fitbit_user.access_token,
      expiry:         DateTime.now + (fitbit_user.expires_every.to_i - 20).seconds
    )
    log_in(user)
    redirect_to user_path(user)
  end
end
