require './data_parser'

class Repository

	@data

	def initialize
		#Initialise le repository ,permet d'importer de autre chose si on veux. 
		parser =DataParser.new
		@data=parser.getDataFromFile

	end

	def getSuggestionsWithParams(keyword)
		matchingCities=[]
		@data.each do |city|
			if city[:name].to_s.downcase.include? keyword.downcase
				if city[:population].to_i > 10000
				matchingCities << city
				end
			end
		end
	return matchingCities
	end

end