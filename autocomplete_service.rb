require './repository.rb'

class AutocompleteService

	@repository

	def initialize
		@repository = Repository.new
	end

	def getSuggestions(keyword)

		if keyword.empty?
			return []		
		else
			test = @repository.getSuggestionsWithParams(keyword)
			formatedSuggestions = []
			formatedSuggestions << {
				:name => test.first[:name]
			}
			return formatSuggestions(test)
		end
	end


	def formatSuggestions(cities)
		formatedSuggestions =[]
		cities.each do |city|
			(city[:country]=='CA')? country='CANADA'  : country="USA"
			country =="CANADA"? state = getProvince(city[:state]) : state = city[:state] 
			
			formatedSuggestions << {
				:name => city[:name]+', '+state+', '+country,
				:latitude => city[:latitude],
				:longitude => city[:longitude],
				:score => city[:score],
			}
		end
		
		return formatedSuggestions
	end

	def getProvince(provinceIndex)
		province = case provinceIndex.to_i	
			when 1 then 'AB'
			when 2 then 'BC'
			when 3 then 'MB'
			when 4 then 'NB'
			when 5 then 'NL'
			when 6 then 'NS'
			when 7 then 'NT'
			when 8 then 'NU'
			when 9 then 'ON'
			when 10 then 'PE'
			when 11 then 'QC'
			when 12 then 'SK'
			when 13 then 'YT'
		end	
	end

	def updateScores(cities)
		#TODO add confidence
	end

end