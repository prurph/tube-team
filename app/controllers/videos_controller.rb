class VideosController < ApplicationController
  before_action :authenticate_user!

  def new
    @video = Video.new
  end

  def show
    @video = Video.find(params[:id])
    @on_team = ( @video.team.present? ? @video.team : false )
    @user_team = current_user.team
  end

  def create
    # Redirect away if video already exists (:show will determine if it's on a team)
    exists = Video.find_by_yt_id(video_params[:yt_id])
    if exists
      return redirect_to exists
    end
    # Otherwise create the video so it can be signed
    video_attributes = make_video(video_params[:yt_id])

    # Leave these here so more advanced functionality can be set later
    video_attributes.merge!({
                        salary: 10000000,
                        watches: 0
    })
    video = Video.create(video_attributes)

    # Video exists now, so pass to videos#edit with team info so user can sign
    # This was old, now trying to just incorporate into show page
    # redirect_to edit_team_video_path(current_user.team.id, video.id)
    redirect_to video
  end

  def edit
    @team = Team.find(params[:team_id])
    @video = Video.find(params[:id])
  end

  def update
    @team = Team.find(params[:team_id])
    @video = Video.find(params[:id])

    # Make sure someone isn't doing form trickery to change another user's team
    if current_user.team.id != @team.id
      flash[:error] = "You are not the manager of this team."
      # FIX THIS REDIRECT PATH LATER
      redirect_to root
    end

    # Otherwise sign the video to the team
    if @team.videos << @video
      flash[:notice] = "Video signed!"
      redirect_to @team
    else
      flash.now[:alert] = team.errors.full_messages.join(', ')
      redirect_to @video
    end
  end

  def destroy
    team = Team.find(params[:team_id])
    video = Video.find(params[:id])
    if team.user != current_user
      flash[:alert] = "You are not the manager of #{team.name}!"
      return redirect_to team
    end

    if video.destroy!
      flash[:notice] = "#{video.title} is now a free agent!"
      redirect_to team
    else
      flash[:alert] = video.errors.full_messages.join(', ')
    end
  end

  private

  def make_video(youtube_id)
    client = YouTubeIt::Client.new(dev_key: "AIzaSyDeEE8UySfWfxuO3hz_Qwsj4R3atx-OF70")
    video = client.video_by(youtube_id)

    attributes = {
                  yt_id: video.unique_id,
                  title: video.title,
                  initial_watches: video.view_count,
                  author: video.author.name,
                  uploaded_at: video.uploaded_at,
                  embed_html5: video.embed_html5,
                  description: video.description,
                  # Get the largest thumbnail available by sorting on height
                  thumbnail: video.thumbnails.sort_by { |tn| tn.height }.last.url
                 }
    attributes
  end

  def video_params
    params.require(:video).permit(:yt_id)
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
