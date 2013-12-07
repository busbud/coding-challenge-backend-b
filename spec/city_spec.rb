require './spec/spec_helper'
require 'city'

describe City do
  describe 'extract method' do
    before do
      City.all.destroy
    end

    it 'should find a city that have less than 5000 population' do
      City.create(:population => 4999, :name => 'Toronto')
      expect(City.extract('Toronto').count).to be(0)
    end

    it 'should fetch a city that have more that 5000 population' do
      City.create(:population => 5000, :name => 'Toronto')
      expect(City.extract('Toronto').count).to be(1)
    end

    it 'should fetch a city that matches a string partially' do
      City.create(:population => 5000, :name => 'Toronto')
      expect(City.extract('Toro').count).to be(1)
    end

    it 'should return the matching cities in the order of distance from the required coordinate' do
      coord = {:latitude => 43.70011, :longitude => -79.4163}
      london_md = City.create( :name      => "Londontowne, MD, USA",
                               :latitude  => 38.93345,
                               :longitude => -76.54941,
                               :population => 5000)

      london_ont = City.create(:name      => "London, ON, Canada",
                               :latitude  => 42.98339,
                               :longitude => -81.23304,
                               :population => 5000)
                               
      london_oh = City.create( :name      => "London, OH, USA",
                               :latitude  => 39.88645,
                               :longitude => -83.44825,
                               :population => 5000)

      london_ky = City.create(  :name      => "London, KY, USA",
                                :latitude  => 37.12898,
                                :longitude => -84.08326,
                                :population => 5000)

      cities = City.extract('London', coord) 

      expected_order = [london_ont, london_oh, london_md, london_ky]
      cities.each_with_index do |city, index|
        expect(city.id).to be(expected_order[index].id)
      end
    end
  end
end
