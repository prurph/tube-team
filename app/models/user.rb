class User < ActiveRecord::Base

  has_one :team
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable
  validates :username, presence: true, uniqueness: { case_sensitive: false }
end
