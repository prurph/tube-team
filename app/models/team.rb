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
      if (Time.now - video.updated_at > 600) # Don't update if last done <10 min
        video.refresh_watches
        video.update_points(start_time, end_time)
      end
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
