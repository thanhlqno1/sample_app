class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update following followers)
  before_action :load_user, except: %i(index create new)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.all.page(params[:page]).per(Settings.per_page.digit_10)
  end

  def show
    @microposts = @user.microposts.newest.page(params[:page])
                       .per(Settings.per_page.digit_5)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = t("flash.signup.activate")
      redirect_to root_url
    else
      flash.now[:danger] = t("flash.signup.failed")
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t("flash.update.successed")
      redirect_to @user
    else
      flash.now[:danger] = t("flash.update.failed")
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t("flash.delete.successed")
    else
      flash[:danger] = t("flash.delete.failed")
    end
    redirect_to users_url
  end

  def following
    load_relation :following
  end

  def followers
    load_relation :followers
  end

  private

  def load_relation title
    @title = t "stats.#{title}"
    @users = @user.send(title.to_s).page(params[:page])
                  .per(Settings.per_page.digit_10)
    render "show_follow"
  end

  def correct_user
    return if current_user?(@user)

    flash[:danger] = t("flash.edit.wrong_user")
    redirect_to(root_url)
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t("flash.login.warning_admin")
    redirect_to(login_url)
  end

  def load_user
    @user = User.find_by id: params[:id]

    return if @user

    flash[:danger] = t("flash.show.failed")
    redirect_to new_user_path
  end

  def user_params
    params.require(:user).permit(User::ATR_PERMIT)
  end
end
