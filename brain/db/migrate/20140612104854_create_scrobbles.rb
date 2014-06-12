class CreateScrobbles < ActiveRecord::Migration
  def change
    create_table :scrobbles do |t|
      t.string :user
      t.datetime :scrobbled_at

      t.timestamps
    end
  end
end
