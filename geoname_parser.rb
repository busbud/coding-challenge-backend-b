require 'csv'
require 'city'

class GeonameParser
  def self.parse(data)
    lines = data.split("\n")
    lines.shift
    lines.map do |line|
      records = line.split("\t")
      {'name'       => records[1],
       'lat'        => Float(records[4]),
       'long'       => Float(records[5]),
       'population' => Float(records[14])}
    end
  end

  def self.build_city(city_data)
    City.new( :name       => city_data['name'],
              :latitude   => city_data['lat'],
              :longitude  => city_data['long'],
              :population => city_data['population'])
  end
end
