require './config/environment'
require 'sinatra/base'
require 'json'

# http://www.sinatrarb.com/
# Configure Database
# Configure Database
class App < Sinatra::Base
  # Endpoints
  get '/suggestions' do
    params = request.params
    cities = City.extract(params['q'].capitalize) 
    status_code = cities.any? ? 200 : 404
    status status_code 
    {:suggestions => cities.map { |city| city.json_attrs }}.to_json
  end
end
