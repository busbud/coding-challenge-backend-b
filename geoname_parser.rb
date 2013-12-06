require 'csv'

class GeonameParser
  def self.parse(data)
    CSV.parse(data, { :col_sep => "\t", 
                      :headers => true, 
                      :converters => [:numeric] })
  end
end
