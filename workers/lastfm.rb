require 'httpclient'
require 'pry'
require 'json'

class Lastfm

  # TODO: check that we got all the info of the timerange
  def self.scrobble(user, from, to, page = 1)
    response = HTTPClient.get("https://83f99d6a-4a0166229897.my.apitools.com/tracks?user=#{user}&limit=200")
    if response.ok?
      tracks = JSON.parse(response.body)['recenttracks']['track']
      tracks.map!{|t| [t['date']['uts'], t['artist'], t['name'], t['mbid'] ] }
    end

    tracks
  end

end
