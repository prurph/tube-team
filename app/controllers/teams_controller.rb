class TeamsController < ApplicationController

  before_action :authenticate_user!

  def index
  end

  def new
    if current_user.team.present?
      flash[:notice] = "One team per user. Must delete current team first."
      redirect_to action: :show
    end

    @team = Team.new
  end

  def create
    # Is this legit? Current user_id merge into team_params hash.
    team = Team.create!({ user_id: current_user.id }.merge(team_params))

    if current_user.save
      flash[:notice] = "Team created!"
      redirect_to action: :show
    else
      flash.now[:error] = article.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @team = Team.find(current_user.team)
  end

  def update
    @team.update_attributes(team_params)

    if @team.save
      flash[:notice] = "Team name updated!"
      redirect_to action: :show
    else
      flash.now[:error] = article.errors.full_messages.join(', ')
      render :edit
    end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end
end
