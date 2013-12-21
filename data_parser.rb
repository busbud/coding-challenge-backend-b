module DataParser

	def self.getDataFromFile

		file = File.open("data/cities_canada-usa.tsv","rb")
		rawData = file.read
		tableCities=[]
		data = rawData.split("\n")

		data.map do |row|
			splittedRow=row.split("\t")
			splittedRow[8]=='CA'? country='CANADA'  : country="USA"
			country =="CANADA"? state = getProvince(splittedRow[10]) : state = splittedRow[10] 
			tableCities << {
				:id => splittedRow[0], 
				:name => splittedRow[2],
				:latitude => splittedRow[4],
				:longitude => splittedRow[5],
				:country => country,
				:state => state,
				:population => splittedRow[14],
				:score => 1
			} 
		end
		return tableCities
	end

	def self.getProvince(provinceIndex)
		province = case provinceIndex.to_i	
			when 1 then 'AB'
			when 2 then 'BC'
			when 3 then 'MB'
			when 4 then 'NB'
			when 5 then 'NL'
			when 7 then 'NS'
			when 8 then 'ON'
			when 9 then 'PE'
			when 10 then 'QC'
			when 11 then 'SK'
			when 12 then 'YT'
			when 13 then 'NT'
		end	
	end
end