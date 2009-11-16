# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'rpx'

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_rails_rp_example_session_id'
  layout 'default'

  before_filter :get_user_id
  before_filter :rpx_setup

  private

  def get_user_id
    user_id = session[:user_id]
    if user_id
      @current_user = User.find_by_id user_id
    end
    return true
  end

  def rpx_setup
    unless Object.const_defined?(:API_KEY) && Object.const_defined?(:BASE_URL) && Object.const_defined?(:REALM)
      render :template => 'const_message'
      return false
    end
    @rpx = Rpx::RpxHelper.new(API_KEY, BASE_URL, REALM)
    return true
  end
end
