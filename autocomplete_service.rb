require './repository.rb'

class AutocompleteService

	def getSuggestions(keyword)
		repo = Repository.new
		repo.getSuggestionsWithParams(keyword)
	end

end