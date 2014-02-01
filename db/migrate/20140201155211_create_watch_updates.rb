class CreateWatchUpdates < ActiveRecord::Migration
  def change
    create_table :watch_updates do |t|
      t.references :video, index: true
      t.integer :watches
      t.datetime :created_at
    end
  end
end
