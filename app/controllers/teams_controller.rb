class TeamsController < ApplicationController

  before_action :authenticate_user!

  def index
    # Return these in ranked order so we can display rankings
    @teams = Team.all.order(points: :desc)
  end

  def show
    @team = Team.find_by_id(params[:id])
    if @team.videos.empty?
      @team.videos.each do |video|
        video.refresh_watches
        video.update_points
      end
      @team.update_points
      @team.update_watches
    end
    @rank = @team.get_rank
  end

  def new
    if current_user.team.present?
      flash[:alert] = "One team per user. Must release current team first."
      redirect_to action: :show
    else
      @team = Team.new
    end
  end

  def create
    attributes = {
                   user_id: current_user.id,
                   bankroll: 10000000, # This is default starting cash for now
                   salary: 0
                  }
    team = Team.create!(attributes.merge(team_params))

    if current_user.save
      flash[:notice] = "Team created!"
      redirect_to team
    else
      flash.now[:alert] = article.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    if current_user.team.blank?
      flash[:alert] = "No existing teams."
      redirect_to action: :new
    end
    @team = Team.find(current_user.team)
  end

  def update
    team = Team.find(params[:id])
    if current_user.id != team.user_id
      flash[:notice] = "You're not the manager of #{team.name}!"
      return redirect_to team
    else
      team.update_attributes(team_params)
    end

    if team.save
      flash[:notice] = "Team name updated!"
      redirect_to team
    else
      flash.now[:alert] = article.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    team = Team.find(params[:id])
    videos = team.videos

    if current_user.id != team.user_id
      flash[:notice] = "You're not the manager of #{team.name}!"
      return redirect_to team
    else
      # videos have dependent: :destroy relationship with team
      if team.destroy
        flash[:notice] = "Team deleted"
        redirect_to action: :index
      else
        flash[:alert] = team.errors.full_messages.join(', ')
        redirect_to :edit
      end
    end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end
end
