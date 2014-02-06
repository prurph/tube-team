class VideosController < ApplicationController
  before_action :authenticate_user!
  before_action :get_team_and_video, only: [:update, :destroy, :edit]

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
    # Check for traps: form trickery to change another user's team
    # or not enough money to sign

    if current_user.team.id != @team.id
      flash[:alert] = "You are not the manager of #{team.name}!"
      # Confused on when I need explicit returns with redirect_to and render
      return redirect_to team_path(@team)
    elsif @video.team
      flash[:alert] = "Video already on #{video.team.name}"
      return redirect_to team_path(@team)
    elsif exceed_cap(@video.salary)
      flash[:alert] = "Insufficient funds! Find a cheaper player!"
      return redirect_to @video
    end

    # Otherwise sign the video to the team
    if @team.videos << @video
      flash[:notice] = "Video signed! #{@video.salary} deducted."
      @team.update_attributes(bankroll: (@team.bankroll - @video.salary),
                             salary:   (@team.salary + @video.salary))
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

    # run_cleanup handles adding video's points to past_points so teams can
    # track points from videos that they have destroyed
    destro = run_cleanup(@video, @team)
    flash[:notice] = "#{destro[:title]} is now a free agent! You regain #{destro[:salary]}
                        in funds!"
    redirect_to @team
  end

  private

  def run_cleanup(video, team)
    destroyed_title = video.title
    destroyed_salary = video.salary
    ActiveRecord::Base.transaction do
      video.refresh_watches
      video.update_points
      team.update_attributes(bankroll: (team.bankroll + video.salary),
                             salary:   (team.salary - video.salary),
                             past_points: (team.past_points += video.points)
                            )
      team.update_points
      video.destroy
    end
    return {title: destroyed_title, salary: destroyed_salary}
  end

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
