class AddBankrollToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :bankroll, :integer
  end
end
