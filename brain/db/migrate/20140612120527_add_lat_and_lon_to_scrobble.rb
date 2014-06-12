class AddLatAndLonToScrobble < ActiveRecord::Migration
  def change
    add_column :scrobbles, :lat, :float
    add_column :scrobbles, :lon, :float
  end
end
