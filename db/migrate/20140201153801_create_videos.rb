class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :salary
      t.integer :initial_watches
      t.integer :watches
      t.string :yt_id
      t.string :description
      t.datetime :uploaded_at
      t.string :author
      t.string :embed_html5
      t.references :team, index: true
    end
  end
end
