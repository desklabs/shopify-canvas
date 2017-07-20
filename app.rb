require 'sinatra'
require 'shopify_api'
require 'dotenv/load'
require 'openssl'
require 'Base64'
require 'json'

shop_url = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV["SHOPIFY_API_SECRET"]}@#{ENV["SHOPIFY_HOST"]}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url


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
  result = verify_and_return_context(request)
  session['auth'] = result[0]
  shopify_customer = search_shopify_customer(result[1])

  halt 401 unless session['auth']

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

#Parses the canvas request body and a verifies the CanvasObject based on the shared key.
#Returns: [verified true/false, decoded context]

def verify_and_return_context(request)
  request.body.rewind  # in case someone already read it

  data = URI.unescape(request.body.read.to_s.split('signed_request=')[1])
  hashed_context = data.split('.')[0]
  context        = data.split('.')[1]

  signed_context = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), ENV['CANVAS_KEY'], context)
  hash = Base64.strict_encode64(signed_context).strip()
  return [hashed_context == hash, Base64.decode64(context)]
end

#Searches Shopify for a customer based on the Desk context
#returns a shopify customer object
def search_shopify_customer(context)
  context = JSON.parse(context)
  customer_emails = context['context']['environment']['customer']['emailAddresses']
  customer_email = customer_emails.length > 0 ? customer_emails.first['value'] : ""

  @shopify_customer = ShopifyAPI::Customer.search(query: customer_email).first
  return @shopify_customer
end

#Searches Shopify for a specific order by name or order_id
#Returns a single order object
def search_shopify_order(search)
  count = ShopifyAPI::Order.count
  pages = count / 250
  pages = pages.to_i + 1
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
