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
        city.alt_name = city.alt_name.split(',')
        @cities << city
      end
    end
    @cities.shift # Header row
  end

  # Suggest cities by length of matching portion of name
  def by_name(query)
    scores = Hash.new
    @cities.each do |city|
      match = [city.name, city.ascii, *city.alt_name].find do |name|
        name.downcase.include? query.downcase
      end
      scores[city] = query.length / match.length.to_f if match
    end
    scores
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

    suggestions = settings.suggest.by_name(query).map do |city, score|
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
