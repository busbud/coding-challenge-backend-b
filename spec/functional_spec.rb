require 'spec_helper'

shared_examples_for 'a valid response' do |city_regexp|
  it 'returns a 200' do
    expect(response.status).to eq(200)
  end

  it 'returns an array of suggestions' do
    expect(response.json_body['suggestions']).to be_a(Array)
    expect(response.json_body['suggestions']).to_not be_empty
  end

  it 'contains a match' do
    names = response.json_body['suggestions'].map { |r| r['name'] }
    expect(names.grep(city_regexp)).to_not be_empty
  end

  it 'contains latitudes and longitudes' do
    response.json_body['suggestions'].each do |result|
      expect(result['latitude']).to_not be_nil
      expect(result['longitude']).to_not be_nil
    end
  end

  it 'contains scores' do
    response.json_body['suggestions'].each do |result|
      expect(result['score']).to_not be_nil
    end
  end
end

describe 'GET /suggestions' do
  describe 'without a query' do
    subject(:response) do
      get '/suggestions'
    end

    it 'returns a 400' do
      expect(response.status).to eq(400)
    end
  end

  describe 'with a non-existent city' do
    subject(:response) do
      get '/suggestions', {:q => 'SomeRandomCityInTheMiddleOfNowhere'}
    end

    it 'returns a 404' do
      expect(response.status).to eq(404)
    end

    it 'returns an empty array of suggestions' do
      expect(response.json_body['suggestions']).to be_a(Array)
      expect(response.json_body['suggestions']).to have(0).items
    end
  end

  describe 'with a parital match' do
    subject(:response) do
      get '/suggestions', {:q => 'M'}
    end

    it_should_behave_like 'a valid response', /montréal/i
  end

  describe 'with accented characters in query' do
    subject(:response) do
      get '/suggestions', {:q => 'Mā‘'}
    end

    it_should_behave_like 'a valid response', /Mā‘ili/
  end

  describe 'with a valid city' do
    subject(:response) do
      get '/suggestions', {:q => 'Montreal'}
    end

    it_should_behave_like 'a valid response', /montréal/i
  end

  describe 'with a valid city, and valid longitude and latitude' do
    subject(:response) do
      get '/suggestions', {:q => 'Montreal', :longitude => '45.28378', :latitude => '-87.3828'}
    end

    it_should_behave_like 'a valid response', /montréal/i
  end

  describe 'with a valid city, and invalid longitude and latitude' do
    subject(:response) do
      get '/suggestions', {:q => 'Montreal', :longitude => 'hi', :latitude => 'mom'}
    end

    it_should_behave_like 'a valid response', /montréal/i
  end
end
