class Team < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true, uniqueness: true
  validates :user_id, presence: true, uniqueness: true
end
