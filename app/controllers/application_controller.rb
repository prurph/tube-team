class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?


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

  def refresh_watches(video_id)
    video = Video.find(video_id)

    client = YouTubeIt::Client.new(dev_key: "AIzaSyDeEE8UySfWfxuO3hz_Qwsj4R3atx-OF70")
    new_data = client.video_by(video.yt_id)

    attributes = {
                  watches: new_data.view_count
    }

    # Update the watch count in the video entry itself to track watches since
    # joining the user's team
    video.update_attributes(watches: (new_data.view_count - video.initial_watches))
    # And create a timestamped watch
    update = WatchUpdate.create(attributes)
    video.watch_updates << update
    video.save
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
    # devise_parameter.sanitizer.for(:sign_up) do |user|
    #   user.permit :username, :email, :password, :password_confirmation
    # end
  end
end
