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
			suggestions.size>0? updatedSuggestions = addScores(suggestions,options) : updatedSuggestions =[];
			return formatSuggestions(updatedSuggestions)
		end
	end

	private

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

	def addScores(cities,options={})
		citiesSortedByPopulation = cities.sort_by { |city| city[:population].to_i }
		citiesSortedByDistance = cities.sort_by { |city| city[:distanceFromPosition].to_i }

		cities.each do |city|
			value=[]
			value = {
				:ptsForPopulation => (((citiesSortedByPopulation.index{|x| x[:id]==city[:id]})+1).to_f / citiesSortedByPopulation.size.to_f),
				:ptsForRelevency => (options[:keyword].length.to_f / city[:name].length.to_f),
				:ptsForDistance => (((citiesSortedByDistance.index{|x| x[:id]==city[:id]})+1).to_f / citiesSortedByDistance.size.to_f)
			}

			!(options[:latitude].nil? || options[:longitude].nil? || options[:latitude].to_s.empty? || options[:longitude].to_s.empty?)?
				(city[:score]=chooseEquation(value,1).round(1)) : (city[:score]=chooseEquation(value,2).round(1))
		end 
		return cities
	end

	#Pourrais ajouter differente equations si on ajoutais des parametres a prendre en consideration
	def chooseEquation(value,method)
		score = case method
			when 1 then (0.6*value[:ptsForRelevency].to_f + 0.1*value[:ptsForDistance].to_f + 0.3*value[:ptsForPopulation].to_f)
			when 2 then (0.5*value[:ptsForRelevency].to_f + 0.5*value[:ptsForPopulation].to_f)
		end
	end


end