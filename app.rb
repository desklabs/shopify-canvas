require 'sinatra'
require 'shopify_api'
require 'dotenv/load'
require 'openssl'
require 'Base64'
require 'json'

shop_url = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV["SHOPIFY_API_SECRET"]}@#{ENV["SHOPIFY_HOST"]}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

puts shop_url

puts "---Checking Shopify Authentication---"
shop = ShopifyAPI::Shop.current
puts shop
puts "----"

set :protection, :except => :frame_options
enable :sessions

#####        #####
###   Routes   ###
#####        #####

before do 
  pass if request.path_info == '/'
  
  if session['auth'] then pass else halt 401 end
end

get '/' do
  halt 401
end

post '/' do 
  session['auth'] = verify_context unless session['auth']

  halt 401 unless session['auth']
  
  shopify_customer = search_shopify_customer(decode_context)

  if shopify_customer 
    haml :index, :layout => :shopify, :locals => {:customer => shopify_customer, :orders => shopify_customer.orders}
  else
    haml :order, :layout => :shopify
  end
end

post '/order_search' do
  order_search = params[:order_search]

  order_search_result = search_shopify_order(order_search)
  haml :order_search_results, :layout => :shopify, :locals => {:order=> order_search_result}
end

#####         #####
###   HELPERS   ###
#####         #####

##
#Parses the canvas request body and a verifies the CanvasObject based on the shared key.
#
def verify_context
  data = parsed_request.split('.')
  hashed_context = data[0]
  @context       = data[1]

  hash = Base64.strict_encode64(signed_context).strip()
  return hashed_context == hash
end

##
#Sinatra request body needs to be uri unescaped for some reason
#
def parsed_request
  request.body.rewind

  data = URI.unescape(request.body.read.to_s.split('signed_request=')[1])
end

##
#Sign the context with the canvas shared key
#
def signed_context
  signed_context = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), ENV['CANVAS_KEY'], @context)
end

##
#Parses context and base64 decodes
#
def decode_context
  data = parsed_request
  
  context = Base64.decode64(data.split('.')[1])
end

#Searches Shopify for a customer based on the Desk context
#returns a shopify customer object
def search_shopify_customer(context)
  customer_emails = context_customer_emails(context)
  shopify_customer = nil

  customer_emails.each do |customer_email|
    shopify_customer = ShopifyAPI::Customer.search(query: customer_email).first
    break if shopify_customer
  end

  return shopify_customer
end

#returns an array of customer emails from the raw context
def context_customer_emails(context)
  context = JSON.parse(context)
  customer_emails = context['context']['environment']['customer']['emailAddresses']
  customer_emails = customer_emails.map {|x| x["value"]}
end

#Searches Shopify for a specific order by name or order_id
#Returns a single order object
def search_shopify_order(search)
  count = ShopifyAPI::Order.count
  pages = (count / 250) + 1
  order = nil

  begin
      orders = ShopifyAPI::Order.find(:all, params: {limit: 250, page: pages})
      orders.each do |o|
        if o.order_number.to_s == search.to_s
          order = o
        elsif o.name.to_s == search.to_s
          order = o 
        end
      end
      pages -= 1
      break if order
  end while pages > 0

  return order
end
