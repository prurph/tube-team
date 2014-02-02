class Team < ActiveRecord::Base
  belongs_to :user
  has_many :videos, dependent: :destroy # Videos destroyed when team is

  validates :name, presence: true, uniqueness: true
  validates :user_id, presence: true, uniqueness: true

  def update_points(start_time=Time.new(1982), end_time=Time.now)
    to_add = 0

    self.videos.each do |video|
      video.update_points(end_time, start_time)
      to_add += video.points
    end

    self.update_attributes(points: points)
  end
end
