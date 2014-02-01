class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @team = @user.team
    @me = (@user == current_user)
    @videos = @team.videos
    @rank = get_rank(@team)
  end

  private

  def get_rank(team)
    # This is probably not a good idea to do every time someone loads a team
    # later create a ranking field for users and run a rake task to update it
    # periodically
    Team.all.order(:points).index(team)
  end

end
