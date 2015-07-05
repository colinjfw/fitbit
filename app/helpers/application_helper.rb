module ApplicationHelper

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session[:user_id] = nil
  end

  def current_user
    User.find_by(id: session[:user_id])
  end

end
