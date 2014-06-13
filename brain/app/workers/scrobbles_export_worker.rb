require 'uri'
require 'net/http'
require 'pry'

class ScrobblesExportWorker
  include Sidekiq::Worker

  def perform(scrobbles)
    table   = "stu"
    inserts = []

    scrobbles.each do |scrobble_id|
      scrobble = Scrobble.find(scrobble_id)
      columns  = ["userr", "track", "lon", "lat", "scrobbled_at"]
      values   = [
        "'#{scrobble.user}'",
        "'#{scrobble.track.name}'",
        scrobble.lon,
        scrobble.lat,
        scrobble.scrobbled_at,
      ]

      inserts << "INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{values.join(', ')})"
    end

    uri    = URI("https://372c006e-4a0166229897.my.apitools.com/sql")
    params = { q: inserts.join('; ') }

    uri.query = URI.encode_www_form(params)
    res   = Net::HTTP.get_response(uri)
  end
end
