class UsersController < ApplicationController
  include UsersControllerHelpers
  before_action :correct_user,  except: [:create]
  before_action :not_expired,   except: [:create]
  rescue_from Oauth2Rails::Errors::Unauthorized, with: :login_again

  def create
    user = User.find_by(email: params[:user][:email])
    if user
      if user.password == params[:user][:password]
        redirect_to Oauth2Rails::Auth.new(state: user.email ).authorize_url
      else
        flash[:danger] = 'Password was incorrect'
        redirect_to root_path
      end
    else
      new_user = User.create(
        email:    params[:user][:email],
        password: params[:user][:password],
        name:     params[:user][:name]
      )
      redirect_to Oauth2Rails::Auth.new(state: new_user.email ).authorize_url
    end
  end

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

end
