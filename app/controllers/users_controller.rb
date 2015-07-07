class UsersController < ApplicationController
  before_action :correct_user
  rescue_from FitbitOauth2::Errors::Unauthorized, with: :login_again

  def show
    @user = User.find(params[:id])
    if params[:date]
      data = get_data(@user, params[:date])
      if data.sleep
        @data = data
      end
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to root_path
  end

  def logout
    logout if session[:user_id] == params[:id]
    redirect_to root_path
  end

  private
    def get_data(user, date)
      data = user.data.find_by(day: date)
      if data.nil?
        fitbit_sleep = user.fitbit_api.sleep(date).to_json
        fitbit_heart = user.fitbit_api.daily_heart(date).to_json
        Datum.create!(
          user_id: user.id,
          day: date,
          heart_series: fitbit_heart,
          sleep_series: fitbit_sleep
        )
      else
        data
      end
    end

    def correct_user
      unless current_user.id == params[:id].to_i
        redirect_to root_path
      end
    end

    def login_again
      redirect_to FitbitOauth2::Oauth2.new.authorize_url
    end

end
