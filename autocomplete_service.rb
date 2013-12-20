require './repository.rb'

class AutocompleteService


	def initialize
		@repository = Repository.new
	end

	def getSuggestions(options={})


		if  options[:keyword].nil? || options[:keyword].empty?
			return []		
		else
			suggestions = @repository.getSuggestionsWithParams(options)
			suggestions.size>0? updatedSuggestions = updateScores(suggestions,options[:keyword]) : updatedSuggestions =[];
			return formatSuggestions(updatedSuggestions)
		end
	end


	def formatSuggestions(cities)
		formatedSuggestions =[]
		cities.each do |city|
			formatedSuggestions << {
				:name => city[:name]+', '+city[:state]+', '+city[:country],
				:latitude => city[:latitude],
				:longitude => city[:longitude],
				:score => city[:score],
			}
		end
		return formatedSuggestions.sort_by{ |city| -city[:score].to_f }
	end



	def updateScores(cities,keyword)

		largestPopulation = ((cities.sort_by { |city| city[:population].to_i }).last)[:population].to_i
		
		cities.each do |city|
			score = 0.5*(keyword.length.to_f / city[:name].length.to_f) + 0.5*(city[:population].to_f/largestPopulation.to_f)
			city[:score] = score.round(1)
		end 

		return cities
	end


end