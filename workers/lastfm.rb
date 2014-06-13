require 'httpclient'
require 'pry'
require 'json'

class Lastfm


  # def self.get_results()

  # TODO: check that we got all the info of the timerange
  def self.scrobble(user, from, to, page = 1)
    response = HTTPClient.get("https://83f99d6a-4a0166229897.my.apitools.com/tracks?user=#{user}&page=#{page}&limit=200")
    if response.ok?
      body = JSON.parse(response.body)
      tracks = body['recenttracks']['track']
      tracks.map!{|t| [t['date']['uts'], t['artist'], t['name'], t['mbid'] ] }
    end

    attrs = body['recenttracks']['@attr']

    if attrs['page'] < attrs['totalPages'] && page < 5
      next_tracks, attrs = scrobble(user, from, to, page = page+1)
      tracks =  tracks + next_tracks
    end

    return tracks, attrs
  end

end
