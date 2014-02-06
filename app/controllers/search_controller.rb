# Prepare new search if user is eligible to search
class SearchController < ApplicationController
  before_action :authenticate_user!

  def new
    user_team = current_user.team
    if !user_signed_in? || user_team.blank?
      flash[:alert] = "Please create a team before scouting for players."
      return redirect_to new_team_path
    elsif user_team.videos.length >= 5
      flash[:alert] = "Teams have a maximum of 5 players. Release videos before
                       scouting for more."
      redirect_to user_team
    end
    @video = Video.new
  end
end
