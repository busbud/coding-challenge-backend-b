require 'spec_helper'

describe 'GET /suggestions' do
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

  describe 'with a valid city' do
    subject(:response) do
      get '/suggestions', {:q => 'Montreal'}
    end

    it 'returns a 200' do
      expect(response.status).to eq(200)
    end

    it 'returns an array of suggestions' do
      expect(response.json_body['suggestions']).to be_a(Array)
      expect(response.json_body['suggestions']).to_not be_empty
    end

    it 'contains a match' do
      names = response.json_body['suggestions'].map { |r| r['name'] }
      expect(names.grep(/montr[eé]al/i)).to_not be_empty
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

  describe "with city and lat but not long" do
    subject(:response) do
      get '/suggestions', {:q => 'london', :latitude => 43.70011}
    end

    it "returns 404" do
      expect(response.status).to eq(404)
    end
  end

  describe "with city and long but not lat" do
    subject(:response) do
      get '/suggestions', {:q => 'london', :longitude => -79.4163}
    end

    it "returns 404" do
      expect(response.status).to eq(404)
    end
  end

  describe 'with valid city and lat/long' do
    subject(:response) do
      get '/suggestions', {:q => 'london', :latitude => 43.70011, :longitude => -79.4163}
    end

    it 'returns a 200' do
      expect(response.status).to eq(200)
    end

    it 'returns an array of suggestions' do
      expect(response.json_body['suggestions']).to be_a(Array)
      expect(response.json_body['suggestions']).to_not be_empty
    end

    it 'contains a match' do
      names = response.json_body['suggestions'].map { |r| r['name'] }
      expect(names.grep(/london/i)).to_not be_empty
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
end