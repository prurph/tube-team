class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all.order :username
  end

  def show
    @user = User.find(params[:id])
    if @user.team.present?
      @team = @user.team
      if @team.videos.present?
        # Update the watches
        # @team.videos.each { |video| video.refresh_watches }
        # @videos = @team.videos
        @team.update_points
        @team.update_watches
      end
    end
  end
end
