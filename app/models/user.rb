class User < ActiveRecord::Base
  has_one :team
  has_many :videos, through: :team
  delegate :name, :watches, to: :team, prefix: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable
  validates :username, presence: true, uniqueness: { case_sensitive: false }
end
