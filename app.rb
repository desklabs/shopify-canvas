require 'sinatra'

set :protection, :except => :frame_options

get '/' do
  File.read('index.html')
end

post '/' do 
  File.read('index.html')
end

