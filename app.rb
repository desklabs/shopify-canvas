require 'sinatra'
require 'redcloth'

get '/' do
  File.read('index.html')
end

get '/parse' do
  body = params[:textile] || ""
  body = body.gsub("??", "<notextile>??</notextile>")
  RedCloth.new(body, [:filter_html, :filter_styles, :filter_classes, :filter_ids, :no_span_caps]).to_html
end
