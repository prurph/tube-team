class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    if @user.team.present?
      @team = @user.team
      if @team.videos.present?
        # Update the watches
        @team.videos.each do |video|
          video.refresh_watches
        end
        @videos = @team.videos
      end
    end
    @me = (@user == current_user)
    @rank = @team.get_rank
  end
end
