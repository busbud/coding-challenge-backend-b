require 'data_mapper'
require 'dm-migrations'
require 'geo-distance'

class City
  include DataMapper::Resource

  property :id        , Serial
  property :name      , String
  property :latitude  , Float
  property :longitude , Float
  property :country   , String
  property :state     , String
  property :population , Integer

  attr_accessor :score

  def self.extract(city_name = '', coords = nil)
    cities = big_city.all(:name.like => "#{city_name}%")
    sorted_cities = sort_cities(cities, coords)
    sorted_cities.each_with_index do |city, index|
      city.score = 1 - index.to_f / cities.count  
    end
  end

  def self.sort_cities(cities, coords = nil)
    if coords
      cities.sort_by do |city|
        distance([city.latitude, city.longitude],
                 [coords[:latitude],  coords[:longitude]])
      end
    else
      cities
    end
  end

  def self.big_city
    all(:population.gte => 5000)
  end

  def self.distance(coord1, coord2)
    # in radians  
    GeoDistance.distance( coord1[0], coord1[1], 
                          coord2[0], coord2[1] )
  end

  def json_attrs
    { :name      => "#{self.name}, #{self.state}, #{self.country}",
      :latitude  => self.latitude.to_f,
      :longitude => self.latitude.to_f,
      :score     => self.score}
  end
end
