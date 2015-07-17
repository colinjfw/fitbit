module UsersControllerHelpers
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
      redirect_to Oauth2Rails::Auth.new(state: current_user.email).authorize_url
    end
  end

  def login_again
    redirect_to Oauth2Rails::Auth.new(state: current_user.email).authorize_url
  end
end