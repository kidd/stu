$:.unshift "./"
$:.unshift "./lib"

# https://maps.google.com/locationhistory/b/0/kml?startTime=1402437600000&endTime=1402524000000
require 'sinatra'
require 'workers/cruncher'
require 'workers/lastfm'
require 'pry'

include FileUtils::Verbose

# datapoint [timestamp, [lat,long]]
# scrobble [timestamp, {song}, artist, mbid]
helpers do
  def mix_n_match(datapoints, scrobbles)
    buckets =  {}
    scrobbles.each do |sc|
      datapoints.inject([]) do |acc, x|
        if sc.first.to_i >= x.first.to_i
          binding.pry
          unless buckets[sc.first.to_i]
            buckets[sc.first.to_i] = {
              lon: x[1][0],
              lat: x[1][1],
              user: 'toni',
              tracks: [
                {
                  name: sc[1],
                  mbid: sc[0][1],
                }
              ]
            }

          else
            buckets[sc.first.to_i][:tracks] << { name: sc[1], mbid: sc[0][1] }  # sc[1] is name, sc[0][1] is artist mbid. change to songmbid
          end
        end
      end
    end
    #   bucket =  data_buckets.select{|db| sc.first.to_i >= db.to_i }.first

    #   if buckets[hora]
    #     buckets[hora] << sc
    #   else
    #     buckets[hora] =  [sc]
    #   end
    # end
    data_buckets
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

  response = mix_n_match(datapoints, scrobbles)
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
