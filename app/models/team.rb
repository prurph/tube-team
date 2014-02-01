class Team < ActiveRecord::Base
  belongs_to :user
  has_many :videos

  validates :name, presence: true, uniqueness: true
  validates :user_id, presence: true, uniqueness: true
end
