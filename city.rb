require 'data_mapper'
require  'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class City
  include DataMapper::Resource

  property :id        , Serial
  property :name      , String
  property :latitude  , Float
  property :longitude , Float
  property :population , Integer

  def self.extract(city_name = '')
    City.all(:population.gte => 5000, :name.like => "#{city_name}%")
  end
end



