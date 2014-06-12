require 'httpclient'
require 'pry'

class Lastfm
  def self.scrobble(user)
    response = HTTPClient.get("https://83f99d6a-4a0166229897.my.apitools.com/tracks?user=#{user}")
    if response.ok?
      JSON.parse(response.body)
    end
  end

end
