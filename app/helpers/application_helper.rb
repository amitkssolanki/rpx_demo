# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def rpx_signin_url
    dest = url_for :controller => :rpx, :action => :login_return, :only_path => false
    @rpx.signin_url(dest)
  end

  def rpx_associate_url
    dest = url_for :controller => :rpx, :action => :associate_return, :only_path => false
    @rpx.signin_url(dest)
  end

  def widget_url
    BASE_URL + '/openid/v2/widget'
  end
end
