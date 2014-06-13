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

    current_datapoint = 0
    scrobbles.map do |sc|
      datapoints.inject({}) do |acc, x|
        if sc.first.to_i >= x.first.to_i
          unless acc[x.first.to_i]
            acc[x.first.to_i] = {
              lon: x[1][0],
              lat: x[1][1],
              user: user_name,
              tracks: [
                {
                  name: sc[2],
                  mbid: sc[3],
                }
              ]
            }
            break acc
          else
            acc[x.first.to_i][:tracks] << { name: sc[2], mbid: sc[3] }  # sc[1] is name, sc[0][1] is artist mbid. change to songmbid
            break acc
          end
        end
        acc
      end
    end
  end
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
    scrobbles = Lastfm.scrobble(lastfm_user, from_date, to_date)
  end

  response = mix_n_match(lastfm_user, datapoints, scrobbles)

  uri    = URI("http://localhost:3000/buckets ")
  response.each do |k, v|
    v['timestamp'] = k
    response = Net::HTTP.post_form(uri, v)
  end


  #uri    = URI("https://372c006e-4a0166229897.my.apitools.com/sql ")
  # params = { q: inserts.join('; ') }
end


__END__
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
