require 'sinatra/base'
require 'json'

# Haversine formula <http://www.movable-type.co.uk/scripts/latlong.html>
module Haversine
  EARTH_RADIUS = 6373 # km

  def self.rad(deg)
    deg * Math::PI / 180
  end

  # Calculate distance in kilometers between two latitude-longitude coordinates
  def self.distance(lat1, long1, lat2, long2)
    lat1 = rad(lat1)
    lat2 = rad(lat2)
    dlat = lat2 - lat1
    dlong = rad(long2 - long1)
    a = Math.sin(dlat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) *
        Math.sin(dlong / 2) ** 2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    EARTH_RADIUS * c
  end

  MAX_DISTANCE = distance(-90, -180, 90, 180)
end

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
        next if city.population.to_i < 5000 # Also eliminates header row
        city.lat, city.long = city.lat.to_f, city.long.to_f
        city.alt_name = city.alt_name.split(',')
        @cities << city
      end
    end
  end

  # Suggest cities by length of matching portion of name
  def by_name(query)
    scores = Hash.new
    @cities.each do |city|
      # Try to match against each name of the city
      match = [city.name, city.ascii, *city.alt_name].find do |name|
        name.downcase.include? query.downcase
      end
      scores[city] = query.length / match.length.to_f if match
    end
    scores
  end

  # Suggest cities by length of matching portion of name and proximity to
  # coordinates
  def by_name_and_coords(query, lat, long)
    scores = by_name(query)
    scores.each_key do |city|
      d = Haversine.distance(city.lat, city.long, lat, long)
      scores[city] *= (Haversine::MAX_DISTANCE - d) / Haversine::MAX_DISTANCE
    end
  end
end

# http://www.sinatrarb.com/
class App < Sinatra::Base
  set :suggest, Suggest.new

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

    if lat
      suggestions = settings.suggest.by_name_and_coords(query, lat, long)
    else
      suggestions = settings.suggest.by_name(query)
    end

    suggestions = suggestions.map do |city, score|
      {
        :name      => "#{city.name}, #{city.country}",
        :latitude  => city.lat,
        :longitude => city.long,
        :score     => score
      }
    end.sort_by {|c| -c[:score] }

    status 404 if suggestions.empty?
    {:suggestions => suggestions}.to_json
  end
end
