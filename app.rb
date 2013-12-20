require 'sinatra/base'
require 'json'

# http://www.sinatrarb.com/
class App < Sinatra::Base
  # Endpoints
  #test initial commit
  get '/suggestions' do
    status 404
    {:suggestions => []}.to_json
  end
end