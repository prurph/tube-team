class UsersController < ApplicationController

  def index
    @users = User.all.order :username
  end

  def show
    @user = User.find(params[:id])
    if @user.team.present?
      @team = @user.team
      if @team.videos.present?
        # Update the watches
        @team.videos.each { |video| video.refresh_watches }
        @videos = @team.videos
      end
      @team.update_points
    end
  end
end
