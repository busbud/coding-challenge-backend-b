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

    it 'should fetch a city that matches the name' do
      City.create(:population => 5000, :name => 'Toronto')
      expect(City.extract('Toronto').count).to be(1)
    end

    it 'should fetch a city that match the first character of the query' do
      City.create(:population => 5000, :name => 'Toronto')
      expect(City.extract('Toro').count).to be(1)
    end
  end
end
