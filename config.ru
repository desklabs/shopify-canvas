require './app.rb'
#if (process.env.NODE_ENV != 'production') 
  require 'dotenv/load'
#end

run Sinatra::Application
