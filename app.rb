require 'sinatra/base'
require 'json'
require_relative 'lib/city_matcher'
require_relative 'lib/city_scorer'
require_relative 'lib/common'

DATA_FILE_LOCATION = './data/cities_canada-usa.tsv'

class App < Sinatra::Base
  set :city_matcher, CityMatcher.new(DATA_FILE_LOCATION)

  helpers do
    def get_possible_cities(query)
      unless $cache
        return settings.city_matcher.possible_cities(query)
      end

      cached_possible_cities = $cache.get(query)
      if cached_possible_cities
        # cache hit
        return Marshal.load(cached_possible_cities)
      end

      # cache miss
      possible_cities = settings.city_matcher.possible_cities(query)
      $cache.set(query, Marshal.dump(possible_cities), 60)
      possible_cities
    end
  end

  get '/suggestions' do
    cache_control :public, :max_age => 30
    content_type :json

    query = request[:q]
    halt 400 unless query
    lat = request[:latitude] ? request[:latitude].to_f : nil
    long = request[:longitude] ? request[:longitude].to_f : nil

    possible_cities = get_possible_cities(query)

    if possible_cities.empty?
      status 404
      {:suggestions => []}.to_json
    else
      city_scorer = CityScorer.new(possible_cities, query, lat, long)
      city_scorer.score_cities
      JSON.pretty_generate({:suggestions => city_scorer.cities_to_hash})
    end
  end
end
