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

  def get_rank
    # This is probably not a good idea to do every time someone loads a team
    # later create a ranking field for users and run a rake task to update it
    # periodically
    Team.all.order(:points).index(self)
  end
end
