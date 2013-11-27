# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'GET /suggestions' do
  describe 'with a non-existent city' do
    subject(:response) do
      get '/suggestions', {:q => 'SomeRandomCityInTheMiddleOfNowhere'}
    end

    it 'returns a 404' do
      expect(response.status).to eq(404)
    end

    it 'is application/json' do
      expect(response.headers['Content-Type']).to eq('application/json;charset=utf-8')
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

  describe 'with an invalid coordinate' do
    subject(:response) do
      get '/suggestions', {:q => 'Montreal', :latitude => 'invalid'}
    end

    it 'returns a 400' do
      expect(response.status).to eq(400)
    end

    it 'returns an array of suggestions' do
      expect(response.json_body['errors']['latitude']).to_not be_nil
      expect(response.json_body['errors']['longitude']).to_not be_nil
    end
  end
end
