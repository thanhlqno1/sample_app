class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_relationship, only: :destroy
  before_action :load_user, only: :create

  def create
    load_relation :follow
  end

  def destroy
    load_relation :unfollow
  end

  private

  def load_relationship
    @user = Relationship.find_by(id: params[:id]).followed
    return if @user

    flash[:danger] = t("relation.invalid_followed")
    redirect_to root_url
  end

  def load_user
    @user = User.find_by id: params[:followed_id]
    return if @user

    flash[:danger] = t("flash.show.failed")
    redirect_to new_user_path
  end

  def load_relation title
    current_user.send(title.to_s, @user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end
end
