
class SiteController < ApplicationController
  def index
    if @current_user
      @identifiers = @rpx.mappings(@current_user.id)
    end
  end

  def login_submit
    u = params[:user]

    user = User.find(:first,
                     :conditions => ['name = ? and pass_hash = ?', u[:name],
                                     Digest::SHA1.hexdigest(u[:password])])

    if user
      session[:user_id] = user.id
    else
      flash[:error] = "Username and password don't match"
    end
      redirect_to :action => "index"
  end

  def logout
    reset_session
    redirect_to :action => "index"
  end

  def create_submit
    u = params[:user]

    if u[:password] != u[:password_confirm]
      flash[:error] = "Passwords must match."
    elsif u[:name].empty?
      flash[:error] = "Username must not be empty"
    else
      begin
        user = User.create(:name => u[:name],
                           :pass_hash => Digest::SHA1.hexdigest(u[:password]))
        session[:user_id] = user.id
      rescue ActiveRecord::StatementInvalid => e
        flash[:error] = "Username not available"
      end
    end
    redirect_to :action => 'index'
  end
end
