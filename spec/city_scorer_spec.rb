require 'json'

require_relative 'spec_helper'
require_relative '../lib/city_scorer.rb'
require_relative '../lib/city_matcher.rb'

describe CityScorer do
  let(:toronto) { CityMatcher::City.new('Toronto, ON, Canada', 43.70011, -79.4163, 4612191) }
  let(:toronto_oh) { CityMatcher::City.new('Toronto, OH, USA', 40.46423, -80.60091, 5091) }
  let(:montreal) { CityMatcher::City.new('Montreal, QC, Canada', 45.50884, -73.58781, 3268513) }

  context '#score_population' do
    subject(:cities) do
      city_scorer = CityScorer.new([toronto, montreal], 'match')
      city_scorer.send(:score_population)
      city_scorer.instance_variable_get(:@cities)
    end

    it 'gives the highest population city the highest score' do
      expect(cities.first.name).to eql(toronto.name)
      expect(cities.first.population_score).to eql(1.0)
    end

    it 'gives a smaller city a lower score' do
      expect(cities.last.name).to eql(montreal.name)
      expect(cities.last.population_score).to eql(montreal.population.to_f / toronto.population)
    end
  end

  context '#score_distance' do
    context 'with lat and long' do
      subject(:cities) do
        city_scorer = CityScorer.new([toronto, montreal], 'match', toronto.lat, toronto.long)
        city_scorer.send(:score_distance)
        city_scorer.instance_variable_get(:@cities)
      end

      it 'gives the closest city the highest score' do
        expect(cities.first.name).to eql(toronto.name)
        expect(cities.first.distance_score).to eql(1.0)
      end

      it 'gives a farther city a lower score' do
        expect(cities.last.name).to eql(montreal.name)
        expect(cities.last.distance_score).to be < 1.0
      end
    end

    context 'without lat and long' do
      it 'does not score distance when lat and long are not provided' do
        city_scorer = CityScorer.new([toronto], 'match')
        city_scorer.send(:score_distance)
        cities = city_scorer.instance_variable_get(:@cities)

        expect(cities.first.distance_score).to be_nil
      end

    end
  end

  context '#score_name_completeness' do
    it 'gives a full match a perfect score' do
      city_scorer = CityScorer.new([toronto], toronto.name)
      city_scorer.send(:score_name_completeness)
      cities = city_scorer.instance_variable_get(:@cities)

      expect(cities.first.name_completeness_score).to be(1.0)
      end

    it 'gives a partial match a non-perfect score' do
      partial_name = 'Tor'
      city_scorer = CityScorer.new([toronto], 'Tor')
      city_scorer.send(:score_name_completeness)
      cities = city_scorer.instance_variable_get(:@cities)
      city_name = cities.first.name

      expect(cities.first.name_completeness_score).to be(partial_name.size / city_name.size.to_f)
    end
  end

  context '#score' do
    it 'scores closer city with larger population higher' do
      city_scorer = CityScorer.new([toronto, toronto_oh], 'To', toronto.lat - 1, toronto.long + 1)
      scored_cities = city_scorer.score_cities

      expect(scored_cities.size).to eql(2)
      expect(scored_cities[0].name).to eql('Toronto, ON, Canada')
      expect(scored_cities[0].score).to be > scored_cities[1].score
    end
  end

  context '#cities_to_hash' do
    it 'converts Citys to hashes' do
      city_scorer = CityScorer.new([toronto], toronto.name)
      city_scorer.score_cities

      response = city_scorer.cities_to_hash
      expect(response.count).to eql(1)
      expect(response[0]['name']).to eql(toronto.name)
      expect(response[0]['score']).to eql(1.0)
      expect(response[0]['latitude']).to eql(toronto.lat)
      expect(response[0]['longitude']).to eql(toronto.long)
    end
  end
end
