class DataParser

	def getDataFromFile

		file = File.open("data/cities_canada-usa.tsv","rb")
		rawData = file.read
		tableCities=[]
		data = rawData.split("\n")

		data.map do |row|
		splittedRow=row.split("\t")
		tableCities << {
			:id => splittedRow[0], 
			:name => splittedRow[2],
			:latitude => splittedRow[4],
			:longitude => splittedRow[5],
			:country => splittedRow[8],
			:state => splittedRow[10],
			:population => splittedRow[14],
			:score => 1
		} 
		end
		return tableCities
	end
end