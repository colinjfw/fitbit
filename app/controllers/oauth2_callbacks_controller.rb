class Oauth2CallbacksController < ApplicationController
  def fitbit
    fitbit_user = FitbitOauth2::Oauth2.new.get_token(params[:code])
    user = User.find_or_create_by(uid: fitbit_user.id) do |user|
      user.refresh_token = fitbit_user.refresh_token
      user.access_token = fitbit_user.access_token
      user.name = fitbit_user.full_name
    end
    log_in(user)
    redirect_to user_path(user)
  end
end
