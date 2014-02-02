class AddPointsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :points, :integer
  end
end
