class TrackDataWorker
  include Sidekiq::Worker

  def perform(track_id)
    track = Track.find(track_id)

    uri = URI("https://7d05ce34-4a0166229897.my.apitools.com/recording/#{track.mbid}")
    params = {
      inc: "releases artist-credits tags"
    }
    uri.query = URI.encode_www_form(params)
    res       = Net::HTTP.get_response(uri)
    info      = Hash.from_xml(res.body)["metadata"]

    # length = info["recording"]["length"]
    # artist = info["recording"]["artist_credit"]["name"]
    # genre  = info["recording"]["tag_list"]["tag"]["name"]

    # track.update_attributes(
    #   genre: genre,
    # )
  end
end
