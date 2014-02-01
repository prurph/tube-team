class TeamsController < ApplicationController

  before_action :authenticate_user!

  def index
    # Return these in ranked order so we can display rankings
    @teams = Team.all.order(:points)
  end

  def show
    @team = Team.find(params[:id])
    @is_me = (@team.user == current_user)
    @videos = @team.videos
    @rank = get_rank(@team)
  end

  def new
    if current_user.team.present?
      flash[:alert] = "One team per user. Must delete current team first."
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
      flash.now[:alert] = article.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    if !current_user.team.present?
      flash[:alert] = "No existing teams."
      redirect_to action: :new
    end
    @team = Team.find(current_user.team)
  end

  def update
    team = Team.find(params[:id])
    if current_user.id != team.user_id
      flash[:notice] = "You're not the manager of #{team.name}"
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
      # Transaction should require that we destroy (release) all videos and team
      # together or neither happens
      ActiveRecord::Base.transaction do
        videos.each { |video| video.destroy! }
        team.destroy!

        # Probably want a rescue block in here?

        flash[:notice] = "Team deleted"
        redirect_to action: :index
      end
    end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end

  def get_rank(team)
  # This is probably not a good idea to do every time someone loads a team
  # later create a ranking field for users and run a rake task to update it
  # periodically
  Team.all.order(:points).index(team)
  end
end
