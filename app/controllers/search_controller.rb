class SearchController < ApplicationController
  before_action :authenticate_user!

  def new
    if !user_signed_in? || current_user.team.blank?
      flash[:alert] = "Please create a team before scouting for players."
      return redirect_to new_team_path
    elsif current_user.team.videos.length >= 5
      flash[:alert] = "Teams have a maximum of 5 players. Release videos before
                       scouting for more."
      redirect_to current_user.team
    end
    @video = Video.new
  end
end
