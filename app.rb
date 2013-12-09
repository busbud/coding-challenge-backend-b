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
    coords = {:latitude => params['latitude'], :longitude => params['longitude']}
    cities = City.extract(params['q'].capitalize, coords) 
    status_code = cities.any? ? 200 : 404
    status status_code 
    {:suggestions => cities.map { |city| city.json_attrs }}.to_json
  end
end
