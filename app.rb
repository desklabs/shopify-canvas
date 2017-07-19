require 'sinatra'
require 'shopify_api'
require 'dotenv/load'

api_key  = ENV['SHOPIFY_API_KEY']
api_pass = ENV["SHOPIFY_API_SECRET"]
host     = ENV["SHOPIFY_HOST"]
shop_url = "https://#{api_key}:#{api_pass}@#{host}.myshopify.com/admin"
puts shop_url
ShopifyAPI::Base.site = shop_url

puts "---Checking Authentication---"
shop = ShopifyAPI::Shop.current
puts shop.to_s


set :protection, :except => :frame_options

get '/' do
  File.read('views/index.html')
end

post '/' do 
  File.read('views/index.html')
end

