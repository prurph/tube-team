class Team < ActiveRecord::Base
  belongs_to :user
  has_many :videos, dependent: :destroy # Videos destroyed when team is

  validates :name, presence: true, uniqueness: true
  validates :user_id, presence: true, uniqueness: true
  scope :all_sorted_by_point_total, order('points + past_points DESC')

  def points_total
    self.points + self.past_points
  end

  def update_points(start_time=Time.new(1982), end_time=Time.now)
    tot_points = 0

    self.videos.each do |video|
      # Don't refresh if updated in past 10 minutes, unless video was created
      # Less than 10 minutes ago (don't want people to lose faith in the
      # system if none of their brand-new videos every update)
      if (Time.now - video.updated_at > 600 && Time.now - video.created_at > 600)
        video.refresh_watches
      end
      video.update_points(start_time, end_time)
      tot_points += video.points
    end
    self.update_attributes(points: tot_points)
  end

  def get_rank
    Team.all.order(points: :desc).index(self) + 1
  end

  def update_watches
    tot_watches = self.videos.inject(0) { |sum, el| sum += el.watches }
    self.update_attributes(watches: tot_watches)
  end

end
