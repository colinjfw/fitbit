require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'create a user test' do
    user = User.new(email: 'cjwalker@sfu.ca', password: 'password')
    assert user.save
    assert user.valid?
    assert user.password == 'password'
  end
end
