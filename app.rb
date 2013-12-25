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

  JSONCity = Struct.new(:name, :latitude, :longitude, :score)
  
  geonamesFile = File.join(File.dirname(__FILE__), "data", "cities_canada-usa.tsv")
  fileOptions = {:col_sep => "\t", :quote_char => "\0", :headers => true, :converters => :numeric}
  
  $bigCities = Array.new
  
  # Data extraction from the CSV file 
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
    query, latitude, longitude = params[:q], params[:latitude], params[:longitude]
    query.gsub! '%20', ' '
    halt 410, "Query is missing !" unless query
    begin
      latitude = Float(latitude) if latitude
      longitude = Float(longitude) if longitude
    rescue
      halt 420, "Latitude and/or longitude is invalid !"
    end 

  # Variables initialization
    @citiesMatching = Array.new   
    earthRadius = 6368

  # Loop on cities which population is over 5000
    $bigCities.each { |cityRow|
      
      if cityRow['name'].start_with? query then
        
      # State translation from number to real name if it's a Canadian city
        if cityRow['country'].eql? "CA" then
            cityState = can_state.fetch(Integer(cityRow['admin1']))
          else
            cityState = cityRow['admin1']
        end
             
        cityName = "#{cityRow['name']}, #{cityState}, #{cityRow['country']}"
        cityLat = Float(cityRow['lat'])
        cityLong = Float(cityRow['long'])

      # Scoring algorithm (involving distance, name and population)             
        lengthDifference = cityRow['name'].length - query.length  
        if latitude && longitude then
          distance = earthRadius*Math.acos(Math.sin(latitude*Math::PI/180)*Math.sin(cityLat*Math::PI/180) + 
                                  Math.cos(latitude*Math::PI/180)*Math.cos(cityLat*Math::PI/180)*Math.cos(longitude*Math::PI/180-cityLong*Math::PI/180)) 
          cityScore = [1 - (distance/3000+0.005) - lengthDifference*0.02, 0].max.round(2)
        else
          distance = 500.0/cityRow['population']
          cityScore = [1 - (distance+0.005) - lengthDifference*0.02, 0].max.round(2)
        end          

      # Results structure
        city = JSONCity.new(cityName, cityLat, cityLong, cityScore) 
        @citiesMatching.push(city)
        
      end
    }
     
  # Sorting results array   
    @citiesMatching.sort! { |a,b| b.score <=> a.score }
      
    end_time = Time.now
    puts "Execution time : #{(end_time-beginning_time)} seconds"
 
  # Return JSON result    
    status 404
    {:suggestions => @citiesMatching.map{|c| Hash[c.each_pair.to_a]}}.to_json
  end

####### 
# END OF Endpoints
#######

end