require './data_parser'
#Utilise le gem geo-distance pour le calcul de la distance entre ville, evite de faire ma propre method de distance similaire a (http://andrew.hedges.name/experiments/haversine/)
require 'geo-distance'

class Repository
	
	def initialize
		#Initialise le repository ,permet d'importer de autre chose si on veux. 
		parser =DataParser.new
		@data=parser.getDataFromFile

	end

	def getSuggestionsWithParams(params={})
		puts params[:latitude]
		puts params[:longitude]


		matchingCities=[]
		@data.each do |city|
			if city[:name].to_s.downcase.start_with? params[:keyword].downcase
				city[:distanceFromPosition] = GeoDistance.distance(city[:latitude],city[:longitude],params[:latitude],params[:longitude])
				matchingCities << city
			end
		end
		puts matchingCities
	return matchingCities
	end

end