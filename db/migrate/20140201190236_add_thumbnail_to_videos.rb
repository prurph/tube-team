class AddThumbnailToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :thumbnail, :text
  end
end
