class TeamsController < ApplicationController

  def index
  end

  def new
    @team = Team.new
  end

  def create
    :authenticate_user! # REFACTOR LATER WITH before_action

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

  private

  def team_params
    params.require(:team).permit(:name)
  end
end
