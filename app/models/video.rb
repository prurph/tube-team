class Video < ActiveRecord::Base
  belongs_to :team
  has_one :user, through: :teams
  has_many :watch_updates, dependent: :destroy # Destroy watch_updates when video is

  validates :yt_id, presence: true, uniqueness: true

  def update_points(start_time=Time.new(1982), end_time=Time.now)
    updates = WatchUpdate.all(conditions:
                              { created_at: (start_time..end_time),
                                video_id: self.id })

    updates.sort! {|update| update.watches }
    binding.pry

    # Short-circuit to assign add_watches to 0 if there are no watch_updates yet
    add_watches = (updates.blank? ? 0 : updates.first.watches - updates.last.watches)

    # Here's where to add in a weighting algorithm based on total watches
    self.update_attributes(points: add_watches)
  end

  def refresh_watches
    client = YouTubeIt::Client.new(dev_key: "AIzaSyDeEE8UySfWfxuO3hz_Qwsj4R3atx-OF70")
    new_data = client.video_by(self.yt_id)

    attributes = {
                  watches: new_data.view_count
    }

    # Update the watch count in the video entry itself to track watches since
    # joining the user's team
    self.update_attributes(watches: (new_data.view_count - self.initial_watches))
    # And create a timestamped watch
    update = WatchUpdate.create(attributes)
    self.watch_updates << update
    self.save
  end
end
