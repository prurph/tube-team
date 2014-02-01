class ConvertTypes < ActiveRecord::Migration
  def change
    change_column :videos, :description, :text
    change_column :videos, :title, :text
    change_column :videos, :description, :text
    change_column :videos, :author, :text
  end
end
