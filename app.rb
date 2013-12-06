require 'sinatra/base'
require 'json'

# http://www.sinatrarb.com/
# Configure Database
# Configure Database
class App < Sinatra::Base
  # Endpoints
  get '/suggestions' do
    status 404
    {:suggestions => []}.to_json
  end
end
