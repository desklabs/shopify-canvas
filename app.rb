require 'sinatra'
require 'shopify_api'
require 'dotenv/load'
require 'openssl'
require 'Base64'
require 'json'

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
  result = verify_and_return_context(request)

  context = JSON.parse(result[1])
  customer_emails = context['context']['environment']['customer']['emailAddresses']
  puts customer_emails
  customer_email = customer_emails.length > 0 ? customer_emails.first['value'] : ""
  puts customer_email

  shopify_customer = ShopifyAPI::Customer.search(query: customer_email)
  if result[0]
    erb :index, :locals => {:result => shopify_customer}
  end
end

def verify_and_return_context(request)
  request.body.rewind  # in case someone already read it
  canvas_key = ENV['CANVAS_KEY']

  data = URI.unescape(request.body.read.to_s.split('signed_request=')[1])
  hashed_context = data.split('.')[0]
  context        = data.split('.')[1]
  

  signed_context = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), canvas_key, context)
  hash = Base64.strict_encode64(signed_context).strip()
  puts "---Request Verified?---"
  puts hashed_context == hash
  puts "-----"
  return [hashed_context == hash, Base64.decode64(context)]
end
