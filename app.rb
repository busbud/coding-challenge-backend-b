require 'sinatra/base'
require 'json'

# http://www.sinatrarb.com/
class App < Sinatra::Base
  # Endpoints
  get '/suggestions' do
    status 404
    {:suggestions => []}.to_json
  end
end