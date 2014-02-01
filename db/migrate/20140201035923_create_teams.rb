class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :salary
      t.text :name
      t.integer :watches, default: 0
      t.references :user, index: true
    end
  end
end
