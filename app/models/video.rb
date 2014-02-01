class Video < ActiveRecord::Base
  belongs_to :team
  has_many :watch_updates

  validates :yt_id, presence: true, uniqueness: true
end
