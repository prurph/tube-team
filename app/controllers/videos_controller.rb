# RESTful actions for videos + create_many for general queries that return
# multiple video models
class VideosController < ApplicationController
  before_action :authenticate_user!
  before_action :get_team_and_video, only: [:update, :destroy, :edit]

  def show
    @videos = Video.includes(:team).where(id: params[:id].split(',')).order(initial_watches: :desc)

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
  end

  def create
    yt_id_parsed = (/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/)
      .match(video_params[:yt_id])

    if !yt_id_parsed
      flash[:alert] = "Invalid search! Are you entering a full YouTube URL?"
      return redirect_to search_new_path
    elsif Video.find_by_yt_id(yt_id_parsed[2])
      return redirect_to Video.find_by_yt_id(yt_id_parsed[2])
    else
      new_video = Video.make_video(yt_id_parsed[2])
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
  end

  def update
    salary = @video.salary

    if current_user.team.id != @team.id
      flash[:alert] = "You are not the manager of #{@team.name}!"
      # Confused on when I need explicit returns with redirect_to and render
      return redirect_to @team
    elsif @video.team
      flash[:alert] = "Video already on team: #{@video.team_name}"
      return redirect_to @team
    elsif exceed_cap(salary)
      flash[:alert] = "Insufficient funds! Find a cheaper player!"
      return redirect_to @video
    end

    # Otherwise sign the video to the team
    if @team.videos << @video
      flash[:notice] = "Video signed! #{salary} deducted."
      @team.update_attributes(bankroll: (@team.bankroll - salary),
                             salary:   (@team.salary + salary))
      redirect_to @team
    else
      flash.now[:alert] = @team.errors.full_messages.join(', ')
      redirect_to @video
    end
  end

  def destroy
    if @team.user != current_user
      flash[:alert] = "You are not the manager of #{team.name}!"
      return redirect_to @team
    end
    # run_cleanup shifts deleted team's points to the team's past_points
    # thus teams track previous points earned by videos they have since released
    destro = @video.run_cleanup
    flash[:notice] = "#{destro[:title]} is now a free agent! You regain " +
                     "#{destro[:salary]} in funds!"
    redirect_to @team
  end

  private
  def get_team_and_video
    @team = Team.find(params[:team_id])
    @video = Video.find(params[:id])
  end

  def video_params
    params.require(:video).permit(:yt_id)
  end

  def exceed_cap(vidsalary)
    current_user.team.bankroll < vidsalary
  end
end
