class VideosController < ApplicationController
  before_action :authenticate_user!

  def show
    @videos = Video.find params[:id].split(',')

    # If only one video stick it in an array so we can iterate over it too
    [@videos] if @videos.class == Video

    @videos.each do |video|
      if video.team.present?
        # If video isn't a free agent refresh the watches (data might be stale)
        # If it's a free agent it was just created so no worries
        video.refresh_watches
      end
      # Update points (for now this updates for all time)
      video.update_points
    end

    @user_team = current_user.team
  end

  # new and create work to find make a single vid from yt_id and

  def new
    if current_user.team.present?
      @video = Video.new
    elsif current_user.team.videos.length >= 5
      flash[:alert] = "Teams have a maximum of 5 players."
      return redirect_to team_video_path(current_user.team.id)
    else
      flash[:alert] = "Please create a team before scouting for players"
      redirect_to new_team_path
    end
  end

  def create
    begin
    # Redirect away if video already exists (#show will determine if it's on a team)
      exists = Video.find_by_yt_id(video_params[:yt_id])

      if exists
        return redirect_to exists
      else
      # Get info from API to make the video
        new_video = Video.make_video(video_params[:yt_id])
        redirect_to :index
      end

    rescue OpenURI::HTTPError
      flash[:alert] = "Invalid YouTube ID"
      redirect_to :back
    end
  end

  # new_search and create_search handle generic search terms (return 5 videos)
  def new_search
    if current_user.team.blank?
      flash[:alert] = "Please create a team before scouting for players"
      redirect_to new_team_path
    end
  end

  def create_search
    # Return an array of video objects
    search_results = Video.make_search_vids(search_params)
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

  def search_params
    params.require(:term)
  end

  def exceed_cap(vidsalary)
    current_user.team.bankroll < vidsalary
  end
end

# Video Schema
#     t.integer  "salary"
#     t.integer  "initial_watches"
#     t.integer  "watches"
#     t.string   "yt_id"
#     t.string   "description"
#     t.datetime "uploaded_at"
#     t.string   "author"
#     t.string   "embed_html5"
#     t.integer  "team_id"
#     t.string   "title"
