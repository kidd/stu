class CreateBuckets < ActiveRecord::Migration
  def change
    create_table :buckets do |t|
      t.string :user
      t.string :timestamp
      t.text :tracks

      t.timestamps
    end
  end
end
