require 'uri'
require 'net/http'
require 'pry'

class ScrobblesExportWorker
  include Sidekiq::Worker

  def perform(scrobbles)
    table   = "stu"

    scrobbles.each_slice(10) do |slice|
      inserts = []

      slice.each do |scrobble_id|
        scrobble = Scrobble.find(scrobble_id)
        columns  = ["userr", "track", "lon", "lat", "genre", "scrobbled_at"]
        values   = [
          "'#{scrobble.user}'",
          "'#{scrobble.track.name}'",
          scrobble.lon,
          scrobble.lat,
          "'#{scrobble.track.genre}'",
          "'#{scrobble.scrobbled_at}'",
        ]

        inserts << "INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{values.join(', ')})"
      end

      uri    = URI("https://372c006e-4a0166229897.my.apitools.com/sql")
      params = { q: inserts.join('; ') }
      uri.query = URI.encode_www_form(params)
      res   = Net::HTTP.get_response(uri)
    end
  end
end
