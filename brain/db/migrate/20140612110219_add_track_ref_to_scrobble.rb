class AddTrackRefToScrobble < ActiveRecord::Migration
  def change
    add_reference :scrobbles, :track, index: true
  end
end
