class TeamsController < ApplicationController

  before_action :authenticate_user!

  def index
    @teams = Team.all
  end

  def show
    @team = Team.find(params[:id])
  end

  def new
    if current_user.team.present?
      flash[:error] = "One team per user. Must delete current team first."
      redirect_to action: :show
    end

    @team = Team.new
  end

  def create
    # Is this legit? Current user_id merge into team_params hash.
    team = Team.create!({ user_id: current_user.id }.merge(team_params))

    if current_user.save
      flash[:notice] = "Team created!"
      redirect_to team
    else
      flash.now[:error] = article.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    if !current_user.team.present?
      flash[:error] = "No existing teams."
      redirect_to action: :new
    end
    @team = Team.find(current_user.team)
  end

  def update
    team = Team.find(params[:id])
    team.update_attributes(team_params)

    if team.save
      flash[:notice] = "Team name updated!"
      redirect_to action: :show
    else
      flash.now[:error] = article.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    team = Team.find(params[:id])
    videos = team.videos

    if current_user.id != team.user_id
      flash[:notice] = "You're not the manager of #{team.name}!"
      redirect_to action: :show
    end

    # Transaction should require that we destroy (release) all videos and team
    # together or neither happens

    ActiveRecord::Base.transaction do
      videos.each { |video| video.destroy! }
      team.destroy!
      flash[:notice] = "Team deleted"
      redirect_to action: :index
    end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end
end
