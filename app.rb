require 'sinatra/base'
require 'json'

# http://www.sinatrarb.com/
class App < Sinatra::Base
  # Endpoints
  get '/suggestions' do
    content_type :json

    query, lat, long = params[:q], params[:latitude], params[:longitude]
    halt 400, {:error => 'No query'}.to_json unless query
    halt 400, {:error => 'Missing coordinate'}.to_json if lat.nil? ^ long.nil?
    begin
      lat = Float(lat) if lat
      long = Float(long) if long
    rescue ArgumentError
      halt 400, {:error => 'Invalid coordinates'}.to_json
    end

    status 404
    {:suggestions => []}.to_json
  end
end
