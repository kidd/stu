class AddGenreToTrack < ActiveRecord::Migration
  def change
    add_column :tracks, :genre, :string
  end
end
