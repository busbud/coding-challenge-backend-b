require 'csv'
require 'city'

class GeonameParser
  def self.reg_codes
    { '01' => 'AB', 
      '02' => 'BC', 
      '03' => 'MB', 
      '04' => 'NB',
      '05' => 'NL',
      '07' => 'NS',
      '08' => 'ON',
      '09' => 'PE',
      '10' => 'QC',
      '11' => 'SK',
      '12' => 'YT' }
  end

  def self.parse(data)
    lines = data.split("\n")
    lines.shift
    lines.map do |line|
      records = line.split("\t")
      {'name'       => records[1],
       'lat'        => Float(records[4]),
       'long'       => Float(records[5]),
       'country'    => records[8],
       'admin1'    =>  records[10],
       'population' => Float(records[14])}
    end
  end

  def self.build_city(city_data)
    City.new( :name       => city_data['name'],
              :latitude   => city_data['lat'],
              :longitude  => city_data['long'],
              :country    => city_data['country'],
              :state      => reg_codes.fetch(city_data['admin1']) { city_data['admin'] },
              :population => city_data['population'])
  end
end
