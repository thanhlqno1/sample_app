class SessionsController < ApplicationController
  before_action :load_user, only: :create

  def new; end

  def create
    if @user.authenticate(params[:session][:password])
      if @user.activated?
        flash[:success] = t("flash.login.successed")
        log_in @user
        params[:session][:remember_me] == "1" ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        flash[:warning] = t("flash.login.invalid_activate")
        redirect_to root_url
      end
    else
      flash.now[:danger] = t("flash.login.invalid_password")
      render :new
    end
  end

  def destroy
    flash[:success] = t("flash.logout")
    log_out
    redirect_to root_url
  end

  private

  def load_user
    @user = User.find_by(email: params[:session][:email].downcase)
    return if @user

    flash.now[:danger] = t("flash.login.invalid_email")
    render :new
  end
end

