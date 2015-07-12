class Oauth2CallbacksController < ApplicationController
  def fitbit
    fitbit_user = Oauth2Rails::Auth.new.get_token(params[:code])
    user = User.find_by(uid: fitbit_user.id)
    if user
      user.update!(
        refresh_token:  fitbit_user.refresh_token,
        access_token:   fitbit_user.access_token,
        name:           fitbit_user.full_name,
        expiry:         Time.now + fitbit_user.expires_every
      )
    else
      user = User.create!(
        refresh_token:  fitbit_user.refresh_token,
        access_token:   fitbit_user.access_token,
        name:           fitbit_user.full_name,
        expiry:         Time.now + fitbit_user.expires_every
      )
    end
    log_in(user)
    redirect_to user_path(user)
  end
end
