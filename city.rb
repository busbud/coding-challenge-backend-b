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

  def self.extract(city_name = '', coords = nil)
    cities = big_city.all(:name.like => "#{city_name}%")
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
end



