class VideosController < ApplicationController
  before_action :authenticate_user!

  def show
    @videos = Video.find params[:id].split(',')
    @videos.sort_by!(&:initial_watches).reverse!

    # If only one video stick it in an array so we can iterate over it too
    [@videos] if @videos.class == Video

    @videos.each do |video|
      if video.team.present?
        # If video isn't a free agent refresh the watches (data might be stale)
        # If it's a free agent it was just created so don't waste the API call
        video.refresh_watches
      end
      # Update points (this can later take datetime ranges for season purposes)
      video.update_points
    end

    @user_team = current_user.team
  end

  def create
    exists = Video.find_by_yt_id(video_params[:yt_id])
    if exists
      return redirect_to exists
    else
      new_video = Video.make_video(video_params[:yt_id])
      redirect_to new_video
    end
  end

  def create_many
    session[:search_term] = params[:search_term]
    search_results = Video.make_search_vids(params[:search_term])
    id_list = search_results.each.map(&:id)
    redirect_to video_path(id_list.join(','))
  end

  def edit
    @team = Team.find(params[:team_id])
    @video = Video.find(params[:id])
  end

  def update
    team = Team.find(params[:team_id])
    video = Video.find(params[:id])

    # Check for traps: form trickery to change another user's team
    # or not enough money to sign

    if current_user.team.id != team.id
      flash[:alert] = "You are not the manager of this team."
      # Do I need a return here? (Any chance other block executes?)
      return redirect_to :back
    elsif exceed_cap(video.salary)
      flash[:alert] = "Insufficient funds!"
      return redirect_to :back
    end

    # Otherwise sign the video to the team
    if team.videos << video
      flash[:notice] = "Video signed! #{video.salary} deducted."
      team.update_attributes(bankroll: (team.bankroll - video.salary),
                             salary:   (team.salary + video.salary))
      redirect_to team
    else
      flash.now[:alert] = team.errors.full_messages.join(', ')
      redirect_to video
    end
  end

  def destroy
    team = Team.find(params[:team_id])
    video = Video.find(params[:id])
    if team.user != current_user
      flash[:alert] = "You are not the manager of #{team.name}!"
      return redirect_to team
    end

    if video.destroy
      flash[:notice] = "#{video.title} is now a free agent! You regain #{video.salary}
                        in funds!"
      team.update_attributes(bankroll: (team.bankroll + video.salary),
                             salary:   (team.salary - video.salary))
      redirect_to team
    else
      flash[:alert] = video.errors.full_messages.join(', ')
    end
  end

  private

  def video_params
    params.require(:video).permit(:yt_id)
  end

  def exceed_cap(vidsalary)
    current_user.team.bankroll < vidsalary
  end
end
