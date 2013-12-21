require 'sinatra/base'
require 'json'
require './autocomplete_service.rb'

# http://www.sinatrarb.com/
class App < Sinatra::Base
  # Endpoints

  autocompleteService = AutocompleteService.new

  get '/suggestions' do
  	params = request.params

  	suggestedCities = autocompleteService.getSuggestions({
  		:keyword => params['q'],
  		:latitude => params['latitude'],
  		:longitude => params['longitude'] 
  		})

	suggestedCities.size>0 ? (status 200) : (status 404)
  	{:suggestions => suggestedCities}.to_json

  end
end