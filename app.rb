require 'sinatra/base'
require 'json'
require './autocomplete_service.rb'

# http://www.sinatrarb.com/
class App < Sinatra::Base
  # Endpoints

  autocompleteService = AutocompleteService.new

  get '/suggestions' do

  	params = request.params

  	suggestedCities =[]
  	suggestedCities = autocompleteService.getSuggestions(params['q'])

   	if (suggestedCities.size > 0)
  		 status 200
  		 {:suggestions => suggestedCities}.to_json
  	else
  		status 404
  		{:suggestions => []}.to_json
  	end

  end
end