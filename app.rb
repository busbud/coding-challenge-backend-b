require 'sinatra/base'
require 'json'
require 'csv'

# http://www.sinatrarb.com/
class App < Sinatra::Base
  
  #simple degree to rad converter
  def radians(value)
    value * Math::PI / 180    
  end
  
  #methode to calculate distance between to long/lag point
  def earth_distance(search_lat, search_long, latitude, longitude)
    12742 *
      Math.atan2(
        Math.sqrt(Math.sin(radians(latitude-search_lat)/2)**2 + (Math.sin(radians(longitude-search_long)/2)**2 * Math.cos(radians(search_lat)) * Math.cos(radians(latitude)))), 
        Math.sqrt(1-Math.sin(radians(latitude-search_lat)/2)**2 + Math.sin(radians(longitude-search_long)/2)**2 * Math.cos(radians(search_lat)) * Math.cos(radians(latitude)))
      )
  end
  
  # Endpoints
  # Score is base on the reverse of the distance, 1 
  get '/suggestions' do
    search_term = (params[:q] || '').downcase
    search_lat, search_long = params[:latitude].to_f, params[:longitude].to_f
    result = []
    CSV.foreach('data/cities_canada-usa.tsv', :headers=>true, :quote_char => "|", :col_sep => "\t") do |data|
      if data['ascii'].downcase.include?(search_term)
        if search_lat!=0 && search_long!=0
          distance = earth_distance(search_lat, search_long, data['lat'].to_f, data['long'].to_f)
          score = (distance == 0 ? 1 : 1/distance)
        else
          score = 0
        end

        result << {name: "#{data['ascii']}, #{data['admin1']}, #{data['country'] == 'CA' ? 'Canada' : 'USA'}, ", latitude: data['lat'], longitude: data['long'], score: score} 
      end
    end
    status result.length > 0 ? 200 : 404
    {:suggestions => result.sort_by { |hsh| hsh[:score] }.reverse}.to_json
  end
end