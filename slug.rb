$:.unshift "./"
$:.unshift "./lib"

require 'sinatra'
require 'workers/cruncher'
require 'pry'

include FileUtils::Verbose

get '/upload' do
    erb :upload
end

post '/upload' do
    tempfile = params[:file][:tempfile]
    filename = params[:file][:filename]
    cp(tempfile.path, "public/uploads/#{filename}")
    Cruncher.process( "public/uploads/#{filename}")
end

__END__
@@upload
<html>
  <body>
<form action='/upload' enctype="multipart/form-data" method='POST'>
    <input name="lastfm-id" type="text"/>
     </br>
    <input name="file" type="file" />
     </br>
    <input type="submit" value="Upload" />
</form>
  </body>
</html>
