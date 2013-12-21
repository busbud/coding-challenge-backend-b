require './data_parser'
#Utilise le gem geo-distance pour le calcul de la distance entre ville, evite de faire ma propre method de distance similaire à (http://andrew.hedges.name/experiments/haversine/)
require 'geo-distance'

class Repository

	def initialize
		#Initialise le repository ,permet d'importer de autre chose si on veux. 
		@data=DataParser.getDataFromFile

	end

	def getSuggestionsWithParams(params={})	
		matchingCities=[]
		
		@data.each do |city|
			if city[:name].to_s.downcase.start_with? params[:keyword].downcase
				if !(params[:latitude].nil? || params[:longitude].nil? || params[:latitude].to_s.empty? || params[:longitude].to_s.empty?)
					city[:distanceFromPosition] = GeoDistance.distance(city[:latitude],city[:longitude],params[:latitude],params[:longitude])
				end
				matchingCities << city
			end
		end
	return matchingCities
	end

end