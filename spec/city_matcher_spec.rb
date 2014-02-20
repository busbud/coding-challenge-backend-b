require_relative 'spec_helper'
require_relative '../lib/city_matcher.rb'

describe CityMatcher do
  let(:test_data_file) { File.join(__dir__, 'data/cities_canada-usa.tsv') }

  context 'initialization' do
    it 'loads a .tsv file upon initialization' do
      city_matcher = CityMatcher.new(test_data_file)
      cities = city_matcher.instance_variable_get(:@cities)

      abbotsford = cities['abbotsford, bc, canada']
      expect(abbotsford.name).to eq('Abbotsford, BC, Canada')
      expect(abbotsford.lat).to eq(49.05798)
      expect(abbotsford.long).to eq(-122.25257)
      expect(abbotsford.population).to eq(151683)
    end
  end

  context '#possible_cities' do
    subject(:city_matcher) do
      CityMatcher.new(test_data_file)
    end

    it 'returns an empty list if no matching city is found' do
      expect(city_matcher.possible_cities('somecitythatdoesntexist')).to be_empty
    end

    it 'matches partial names' do
      possible_cities = city_matcher.possible_cities('A')
      expect(possible_cities.count).to eql(3)
      expect(possible_cities[0].name).to eql('Abbotsford, BC, Canada')
      expect(possible_cities[1].name).to eql('Acton Vale, QC, Canada')
      expect(possible_cities[2].name).to eql('Airdrie, AB, Canada')
    end

    it 'matches full names' do
      possible_cities = city_matcher.possible_cities('acton vale, qc, canada')
      expect(possible_cities.count).to eql(1)
      expect(possible_cities.first.name).to eql('Acton Vale, QC, Canada')
    end

    it 'is case insensitive' do
      possible_cities = city_matcher.possible_cities('aBBotsFoRd')
      expect(possible_cities.count).to eql(1)
      expect(possible_cities.first.name).to eql('Abbotsford, BC, Canada')
    end

    it 'matches multiple cities with the same name' do
      possible_cities = city_matcher.possible_cities('Kirkland')
      expect(possible_cities.count).to eql(2)
      expect(possible_cities.first.name).to eql('Kirkland, ON, Canada')
      expect(possible_cities.last.name).to eql('Kirkland, QC, Canada')
    end

    it 'matches cities with accents without passing accents' do
      possible_cities = city_matcher.possible_cities('Montreal')
      expect(possible_cities.count).to eql(1)
      expect(possible_cities.first.name).to eql('Montréal, QC, Canada')
    end

    it 'matches cities with accents when passing accents' do
      possible_cities = city_matcher.possible_cities('Montréal')
      expect(possible_cities.count).to eql(1)
      expect(possible_cities.first.name).to eql('Montréal, QC, Canada')
    end
  end
end
