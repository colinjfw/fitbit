class UsersController < ApplicationController
  before_action :correct_user
  rescue_from Oauth2Rails::Errors::Unauthorized, with: :login_again

  def show
    logger.info 'test go to show'
    @user = User.find(params[:id])
    if params[:date]
      begin
        @data = @user.get_data(params[:date])
      rescue FitbitData::NoDataError
        @data = false
      end
    end
  end

  def chart
    logger.info params
    @user = User.first #.find(params[:id])
    begin
      @data = @user.get_data(Date.today - 1)
    rescue FitbitData::NoDataError
      @data = false
    end
    render layout: false
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

    def login_again
      redirect_to FitbitOauth2::Oauth2.new.authorize_url
    end

end
