class Video < ActiveRecord::Base
  belongs_to :team
  has_one :user, through: :teams
  has_many :watch_updates, dependent: :destroy # Destroy watch_updates when video is

  validates :yt_id, presence: true, uniqueness: true

  def self.make_attributes(video)
    api_attr = {
                yt_id: video.unique_id,
                title: video.title,
                initial_watches: video.view_count,
                author: video.author.name,
                uploaded_at: video.uploaded_at,
                embed_html5: video.embed_html5({class: 'video-player',
                                                width: '425',
                                                height: '350',
                                                frameborder: '0'}),
                description: video.description,
                # Get the largest thumbnail available by sorting on height
                thumbnail: video.thumbnails.sort_by { |tn| tn.height }.last.url
                }
    custom_attr = { salary: api_attr[:initial_watches],
                            watches: 0,
                            points: 0
                  }
    return api_attr.merge!(custom_attr)
  end

  def self.make_video(youtube_id)
    client = YouTubeIt::Client.new(dev_key: ENV['YT_DEV_KEY'])
    video = client.video_by(youtube_id)
    self.create!(self.make_attributes(video))
  end

  def self.make_search_vids(search_term)
    client = YouTubeIt::Client.new(dev_key: ENV['YT_DEV_KEY'])
    # Run the search and return top 5 results
    videos = client.videos_by(query: search_term).videos.slice!(0,5)
    # Make an array of video objects from the API results
    videos.map! do |video|
      vid_in_db = Video.find_by_yt_id(video.unique_id)
      # If video already exists, use db entry, otherwise make a model from API data
      video = vid_in_db.present? ? vid_in_db : Video.make_video(video.unique_id)
    end
    videos.sort_by!(&:initial_watches)
  end

  def update_points(start_time=Time.new(1982), end_time=Time.now)
    updates = WatchUpdate.where(created_at: (start_time..end_time),
                                video_id: self.id)

    updates.sort_by!(&:watches)

    # Short-circuit to assign add_watches to 0 if there are no watch_updates yet
    add_watches = (updates.blank? ? 0 : updates.last.watches - updates.first.watches)

    # Here's where to add in a weighting algorithm based on total watches
    self.update_attributes(points: add_watches)
    self.save
  end

  def refresh_watches
    client = YouTubeIt::Client.new(dev_key: ENV['YT_DEV_KEY'])
    new_data = client.video_by(self.yt_id)

    attributes = {
                  watches: new_data.view_count
    }

    # Update the watch count in the video entry itself to track watches since
    # joining the user's team
    self.update_attributes(watches: (new_data.view_count - self.initial_watches))

    # Check to see if a watch with this # of views already exists
    existing_update = self.watch_updates.where(video_id: self.id,
                                               watches: new_data.view_count)
    if existing_update.blank?
      update = WatchUpdate.create(attributes)
      self.watch_updates << update
      self.save
    end
  end

end
