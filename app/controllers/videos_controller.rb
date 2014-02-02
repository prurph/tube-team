class VideosController < ApplicationController
  before_action :authenticate_user!

  def new
    if current_user.team.present?
      @video = Video.new
    else
      flash[:alert] = "Please create a team before scouting for players"
      redirect_to new_team_path
    end
  end

  def show
    @video = Video.find(params[:id])

    @on_team = false
    if @video.team.present?
      @on_team = @video.team
      # If video isn't a free agent refresh the watches (data might be stale)
      # If it's a free agent it was just created so no worries
      @video.refresh_watches
      # Update points (for now this updates for all time)
    end
    @user_team = current_user.team
    @video.update_points
  end

  def create
    # Redirect away if video already exists (#show will determine if it's on a team)
    exists = Video.find_by_yt_id(video_params[:yt_id])

    if exists
      return redirect_to exists
    end
    # Otherwise create the video so it can be signed
    video_attributes = make_video(video_params[:yt_id])

    # Leave these here so more advanced functionality can be set later
    # For now salary is equal to watches at time video info is pulled
    video_attributes.merge!({ salary: video_attributes[:initial_watches],
                              watches: 0,
                              points: 0 })
    video = Video.create(video_attributes)

    # Video exists now, so pass to videos#edit with team info so user can sign
    redirect_to video
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
