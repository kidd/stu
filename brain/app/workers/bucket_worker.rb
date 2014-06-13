require 'pry'
class BucketWorker
  include Sidekiq::Worker

  def perform(bucket)
    user      = bucket["user"]
    timestamp = Time.at(bucket["timestamp"].to_i)
    lat       = bucket["lat"]
    lon       = bucket["lon"]

    scrobbles = []
    bucket["tracks"].each do |raw_track|
      track = Track.find_or_create_by(mbid: raw_track["mbid"]) do |t|
        t.name = raw_track["name"]
      end

      scrobbles << Scrobble.create(
        lat:       lat,
        lon:       lon,
        track:     track,
        user:      user,
        scrobbled_at: timestamp,
      )
    end

    unless scrobbles.blank?
      ScrobblesExportWorker.perform_async(scrobbles.map(&:id))
    end
  end
end
