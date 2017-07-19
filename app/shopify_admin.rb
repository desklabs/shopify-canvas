require 'shopify_api'

class ShopifyShop

  def initialize
    api_key  = ENV[SHOPIFY_API_KEY]
    api_pass = ENV[SHOPIFY_API_SECRET]
    host     = ENV[SHOPIFY_HOST]
    shop_url = "https://#{api_key}:#{api_pass}@#{host}.myshopify.com/admin"
    ShopifyAPI::Base.site = shop_url
  end

  def shop
  end 
end
