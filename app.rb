require 'sinatra/base'
require 'json'

class Suggest
  Geoname = Struct.new(:id, :name, :ascii, :alt_name, :lat, :long,
                       :feat_class, :feat_code, :country, :cc2, :admin1,
                       :admin2, :admin3, :admin4, :population, :elevation,
                       :dem, :tz, :modified_at)

  CITIES_FILE = File.join(File.dirname(__FILE__), 'data',
                          'cities_canada-usa.tsv')

  def initialize
    @cities = Array.new
    File.open(CITIES_FILE) do |f|
      f.each_line do |line|
        city = Geoname.new(*line.chomp.split("\t"))
        city.lat, city.long = city.lat.to_f, city.long.to_f
        @cities << city
      end
    end
    @cities.shift # Header row
  end
end

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
