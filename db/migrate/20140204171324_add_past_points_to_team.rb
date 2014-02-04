class AddPastPointsToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :past_points, :integer, default: 0
  end
end
