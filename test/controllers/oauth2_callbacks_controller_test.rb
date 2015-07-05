require 'test_helper'

class Oauth2CallbacksControllerTest < ActionController::TestCase
  test "should get fitbit" do
    get :fitbit
    assert_response :success
  end

end
