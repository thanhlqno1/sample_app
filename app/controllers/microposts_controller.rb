class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :load_micropost_by_current_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = t("micropost.create.successed")
      redirect_to root_url
    else
      flash.now[:danger] = t("micropost.create.failed")
      @feed_items = current_user.feed.page(params[:page]).per(
        Settings.per_page.digit_5
      )
      render "static_pages/home"
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t("flash.delete.successed")
    else
      flash[:danger] = t("flash.delete.failed")
    end
    redirect_to request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def load_micropost_by_current_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    return if @micropost

    flash[:danger] = t("micropost.invalid_user")
    redirect_to root_url
  end
end
