class UsersController < ApplicationController
  before_action :correct_user
  rescue_from Oauth2Rails::Errors::Unauthorized, with: :login_again

  def show
    @user = User.find(params[:id])
  end

  def chart
    user = User.find(params[:id])
    begin
      data = user.get_data(params[:date])
    rescue FitbitData::NoDataError
      data = false
    end
    if data
      respond_to { |format| format.json  { render json: data.data(current_user) } }
    else
      respond_to { |format| format.json  { render json: { noData: 'No sleep data found for today!' } } }
    end
  end

  def analyze
    user = User.find(params[:id])
    if Datum.exists?(date: params[:date])
      data = user.re_analyze_data(params[:date])
      respond_to { |format| format.json  { render json: data.data(current_user) } }
    else
      respond_to { |format| format.json  { render json: { noData: 'No sleep data found for today!' } } }
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
    def correct_user
      if current_user
        unless current_user.id == params[:id].to_i
          redirect_to root_path
        end
      else
        redirect_to root_path
      end
    end

    def not_expired
      if Time.now >= current_user.expiry
        redirect_to Oauth2Rails::Auth.new.authorize_url
      end
    end

    def login_again
      redirect_to Oauth2Rails::Auth.new.authorize_url
    end

end
