require 'sinatra'
require 'redcloth'

set :protection, :except => :frame_options

get '/' do
  File.read('index.html')
end

post '/' do
  File.read('index.html')
end

post '/parse' do
  body = params[:textile] || ""
  body = body.gsub("??", "<notextile>??</notextile>")
  RedCloth.new(body, [:filter_html, :filter_styles, :filter_classes, :filter_ids, :no_span_caps]).to_html
end

options '*' do
 response.headers["Access-Control-Allow-Origin"] = "*"
 halt 200
end
