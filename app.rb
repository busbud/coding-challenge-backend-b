require 'sinatra/base'
require 'json'
require 'csv'

# http://www.sinatrarb.com/
class App < Sinatra::Base

  
####### 
# Script executed on server start (only once)
#######

  def can_state
    {
      1 => 'AB', 
      2 => 'BC', 
      3 => 'MB', 
      4 => 'NB',
      5 => 'NL',
      7 => 'NS',
      8 => 'ON',
      9 => 'PE',
      10 => 'QC',
      11 => 'SK',
      12 => 'YT',
      13 => 'NT',
      14 => 'NU'
    }
  end

# Definition of earth radius for distance calculations  
  def earthRadius
    6368
  end

# Distance between two localisation  
  def geo_distance(latA, latB, longA, longB)
    result = earthRadius*Math.acos(
                            Math.sin(latA*Math::PI/180)*Math.sin(latB*Math::PI/180) + 
                            Math.cos(latA*Math::PI/180)*Math.cos(latB*Math::PI/180) *
                            Math.cos(longA*Math::PI/180-longB*Math::PI/180)
                            )
    return result
  end

# City structure
  JSONCity = Struct.new(:name, :latitude, :longitude, :score)

# Data extraction from the CSV file 
  geonamesFile = File.join(File.dirname(__FILE__), "data", "cities_canada-usa.tsv")
  fileOptions = {:col_sep => "\t", :quote_char => "\0", :headers => true, :converters => :numeric}
  
  $bigCities = Array.new
  
  CSV.foreach(geonamesFile, fileOptions) do |cityRow|
    if cityRow['population'] >= 5000 then
      $bigCities.push(cityRow)
    end
  end
  
####### 
# END OF Script executed on server start (only once)
#######
  
####### 
# Endpoints
#######

  get '/suggestions' do
    
    content_type 'application/json', :charset => 'utf-8'
    
    beginning_time = Time.now
   
  # Checking parameters 
    query, latitude, longitude, limit = params[:q], params[:latitude], params[:longitude], params[:limit]
    query.gsub! '%20', ' '
    halt 410, "Query is missing !" unless query
    begin
      latitude = Float(latitude) if latitude
      longitude = Float(longitude) if longitude
      limit = Integer(limit) if limit
    rescue
      halt 420, "Latitude, longitude or limit is invalid !"
    end 

  # Variables initialization
    @citiesMatching = Array.new   
    
  # Loop on cities which population is over 5000
    $bigCities.each { |cityRow|
      
      if cityRow['ascii'].downcase.start_with? query.downcase.tr("àâçèéêîôùû", "aaceeeiouu") then
        
      # State translation from number to real name if it's a Canadian city
        if cityRow['country'].eql? "CA" then
            cityState = can_state.fetch(Integer(cityRow['admin1']))
          else
            cityState = cityRow['admin1']
        end
             
        cityName = "#{cityRow['ascii']}, #{cityState}, #{cityRow['country']}"
        cityLat = Float(cityRow['lat'])
        cityLong = Float(cityRow['long'])
        cityPop = cityRow['population']
        
      # Scoring algorithm              
        lengthCarac = Float(query.length)/cityRow['name'].length
        populationCarac = 1 - 5000.0/cityPop
         
        if latitude && longitude then
          distanceCarac = 1 - geo_distance(latitude, cityLat, longitude, cityLong) / (Math::PI*earthRadius)
          cityScore = ((lengthCarac+distanceCarac+populationCarac)/3.0).round(2)
        else
          cityScore = ((lengthCarac+populationCarac)/2.0).round(2)
        end  
          
      # Results structure
        city = JSONCity.new(cityName, cityLat, cityLong, cityScore) 
        @citiesMatching.push(city)
        
      end
    }
     
  # Sorting results array by score and alphabetical order (if score is equal)  
    @citiesMatching.sort! { |a,b| [b.score, a.name] <=> [a.score, b.name] }
  
  # Considering the first 'limit' results if limit is given as a parameter  
    if limit then
      @citiesMatching = @citiesMatching.first(limit)
    end
      
    end_time = Time.now
    puts "Execution time : #{(end_time-beginning_time)} seconds"
 
  # Return JSON result    
    if @citiesMatching.empty? then 
      status 404
    else
      status 200
    end
    {:suggestions => @citiesMatching.map{|c| Hash[c.each_pair.to_a]}}.to_json
  end

####### 
# END OF Endpoints
#######

end