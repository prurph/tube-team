# Users controller; currently no show view
class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.includes(:team).order :username
  end

  def show
    @user = User.find(params[:id])
    if @user.team.present?
      @team = @user.team
      if @team.videos.present?
        @team.update_points
        @team.update_watches
      end
    end
  end
end
