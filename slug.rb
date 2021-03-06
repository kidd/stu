$:.unshift "./"
$:.unshift "./lib"

# https://maps.google.com/locationhistory/b/0/kml?startTime=1402437600000&endTime=1402524000000
require 'sinatra'
require 'workers/cruncher'
require 'workers/lastfm'
require 'pry'
require 'net/http'

include FileUtils::Verbose

# datapoint [timestamp, [lat,long]]
# scrobble [timestamp, {song}, artist, mbid]
helpers do

  def mix_n_match(user_name, datapoints, scrobbles)
    buckets = {}

    scrobbles.each do |sc|
      old_index = 0
      datapoint = 0

      datapoints.each_with_index do |e, index|
        if sc.first.to_i < e.first.to_i
          datapoint = datapoints[index]
          break
        else
          old_index = index
        end
      end

      timestamp = datapoint.first.to_i

      buckets[timestamp] ||= {
        lon: datapoint[1][0],
        lat: datapoint[1][1],
        user: user_name,
        tracks: [

        ]
      }
      buckets[timestamp][:tracks] << {name: sc[2],  mbid: sc[3]}
    end

    buckets
  end
end

get '/download' do
  @start_time = (Time.now - (3 * 30 * 24 * 60 * 60)).to_i # 3 months ago
  @end_time   = Time.now.to_i
  erb :download
end

get '/upload' do
    erb :upload
end

post '/upload' do
  if params[:file]
    tempfile = params[:file][:tempfile]
    filename = params[:file][:filename]
    cp(tempfile.path, "public/uploads/#{filename}")
    datapoints = Cruncher.process( "public/uploads/#{filename}")
  end

  # from_date, to_date = [:first, :last].map{|t| Date.parse(datapoints.send(t).first).to_time.to_i }
  from_date, to_date = datapoints.first.first, datapoints.last.first

  if params[:lastfm_user]
    lastfm_user = params[:lastfm_user]
    scrobbles, _ = Lastfm.scrobble(lastfm_user, from_date, to_date)
  end

  response = mix_n_match(lastfm_user, datapoints, scrobbles)

  uri     = URI.parse("http://localhost:3000/buckets")
  header  = { 'Content-Type' => 'application/json' }
  http    = Net::HTTP.new(uri.host, uri.port)


  response.each do |k, v|
    v['timestamp'] = k
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body   = { bucket: v }.to_json
    http.request(request)
  end

  "DONE!"

  #uri    = URI("https://372c006e-4a0166229897.my.apitools.com/sql ")
  # params = { q: inserts.join('; ') }
end


__END__
@@download
<html>
  <body>
  <a href='<%= "https://maps.google.com/locationhistory/b/0/kml?startTime=#{@start_time}&endTime=#{@end_time}" %>'>download location history</a>
  </body>
</html>
@@upload
<html>
  <body>
<form action='/upload' enctype="multipart/form-data" method='POST'>
    <input name="lastfm_user" type="text"/>
     </br>
    <input name="file" type="file" />
     </br>
    <input type="submit" value="Upload" />
</form>
  </body>
</html>
