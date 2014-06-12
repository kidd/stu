$:.unshift "./"
$:.unshift "./lib"

# https://maps.google.com/locationhistory/b/0/kml?startTime=1402437600000&endTime=1402524000000
require 'sinatra'
require 'workers/cruncher'
# require 'workers/lastfm'
require 'pry'

include FileUtils::Verbose

get '/upload' do
    erb :upload
end

post '/upload' do
  if params[:file]
    tempfile = params[:file][:tempfile]
    filename = params[:file][:filename]
    cp(tempfile.path, "public/uploads/#{filename}")
  end
  datapoints = Cruncher.process( "public/uploads/#{filename}")

  from_date, to_date = [:first, :last].map{|t| Date.parse(datapoints.send(t).first).to_time.to_i }

  # if params[:lastfm_user]
  #   lastfm_user = params[:lastfm_user]
  #   Lastfm.scrobble(lastfm_user, from_date, to_date)
  # end
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
