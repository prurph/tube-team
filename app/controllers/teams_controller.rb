# RESTful actions for teams
class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_team, only: [:update, :destroy, :show]

  def index
    # Return these in ranked order so we can display rankings
    @teams = Team.includes(:videos, :user).order('points + past_points DESC')
    @teams.each do |team|
      team.update_points
      team.update_watches
    end
  end

  def show
    # These refresh video information as well
    # Always do points first (it calls video update watches)
    @team.update_points
    @team.update_watches
    @rank = @team.get_rank
    @is_me = current_user.team == @team ? 'me' : nil # Used for styling
  end

  def new
    if current_user.team.present?
      flash[:alert] = "One team per user. Must release current team first."
      redirect_to current_user.team
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
    team = Team.create(attributes.merge(team_params))

    if team.save
      flash[:notice] = "Team created!"
      redirect_to root_path
    else
      flash.now[:alert] = team.errors.full_messages.join(', ')
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
    if current_user.id != @team.user_id
      flash[:notice] = "You're not the manager of #{@team.name}!"
      return redirect_to @team
    else
      @team.update_attributes(team_params)
    end

    if @team.save
      flash[:notice] = "Team name updated!"
      redirect_to @team
    else
      flash.now[:alert] = @team.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    if current_user.id != @team.user_id
      flash[:notice] = "You're not the manager of #{team.name}!"
      return redirect_to @team
    else
      # videos have dependent: :destroy relationship with team
      if @team.destroy
        flash[:notice] = "Team deleted"
        redirect_to action: :new
      else
        flash[:alert] = @team.errors.full_messages.join(', ')
        redirect_to :edit
      end
    end
  end

  private

  def get_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
