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
    yt_id_parsed = (video_params[:yt_id] =~
      /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/)[2]
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
    session[:vid_ids] = id_list
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
      flash[:alert] = "You are not the manager of #{team.name}!"
      # Confused on when I need explicit returns with redirect_to and render
      return redirect_to team_path(team)
    elsif exceed_cap(video.salary)
      flash[:alert] = "Insufficient funds! Find a cheaper player!"
      return redirect_to video
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

    # run_cleanup handles adding video's points to past_points so teams can
    # track points from videos that they have destroyed
    run_cleanup(video)
    video.destroy
    flash[:notice] = "#{video.title} is now a free agent! You regain #{video.salary}
                        in funds!"
    redirect_to team
  end

  private

  def run_cleanup(video)
    ActiveRecord::Base.transaction do
      video.refresh_watches
      video.update_points
      video.team.update_attributes(bankroll: (video.team.bankroll + video.salary),
                             salary:   (video.team.salary - video.salary),
                             past_points: (video.team.past_points += video.points)
                            )
    end
  end

  def video_params
    params.require(:video).permit(:yt_id)
  end

  def exceed_cap(vidsalary)
    current_user.team.bankroll < vidsalary
  end
end
