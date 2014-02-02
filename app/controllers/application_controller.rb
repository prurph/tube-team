class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?


  def make_video(youtube_id)
    client = YouTubeIt::Client.new(dev_key: ENV['YT_DEV_KEY'])
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

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
    # devise_parameter.sanitizer.for(:sign_up) do |user|
    #   user.permit :username, :email, :password, :password_confirmation
    # end
  end
end
