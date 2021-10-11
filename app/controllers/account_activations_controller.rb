class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user&.authenticated?(:activation, params[:id])
      if user.activated?
        flash[:danger] = t("flash.signup.activate_already")
        return redirect_to root_url
      end
      user.activate
      log_in user
      flash[:success] = t("flash.signup.successed")
      redirect_to user
    else
      flash[:danger] = t("flash.signup.invalid_activate")
      redirect_to root_url
    end
  end
end
