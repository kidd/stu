class Track < ActiveRecord::Base
  has_many :scrobbles

  after_create :collect_data

  def collect_data
    TrackDataWorker.perform_async(self.id)
  end
end
