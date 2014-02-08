require 'csv'
require 'geocoder'
require 'active_support/all'

class Suggestion
  attr_accessor :cities
  attr_accessor :q, :latitude, :longitude

  def initialize(cities, params = {})
    params.symbolize_keys!

    @cities    = cities
    @q         = params.fetch(:q, nil)
    @latitude  = params.fetch(:latitude, nil)
    @longitude = params.fetch(:longitude, nil)
  end

  def results
    results = search_according_query.collect do |city|
      {
        :name      => city.complete_name,
        :latitude  => city.latitude,
        :longitude => city.longitude,
        :score     => score_for(city)
      }
    end

    results.sort_by{ |x| x[:name] }
  end

  def errors
    return 'query is mandatory!' if q.blank?

    return 'lat or long missing' if lat_or_long_missing?
  end

  def errors?
    errors.present?
  end

  private

  def query_parameterize
    I18n.transliterate q
  end

  def search_according_query
    cities.select{ |city| city.ascii.match(/^#{query_parameterize}/i) }
  end

  def lat_or_long_missing?
    return true if latitude && longitude.nil?
    return true if longitude && latitude.nil?
  end

  def score_for(city)
    score_by_length_for(city)

  end

  def score_by_length_for(city)
    Float(q.length) / city.ascii.length
  end

end
