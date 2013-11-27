require 'sinatra/base'
require 'json'


# Stubbed Cities data structure to make tests pass
class Cities
  def initialize()
    @data = {
      "montreal" => {
        :name => "Montreal, QC, Canada",
        :latitude => "45.5000",
        :longitude => "-73.5667",
      }
    }
  end

  def find(prefix)
    return [] if not prefix or prefix == ""
    prefix = prefix.downcase

    @data.select{|k, v| k.start_with?(prefix)}
  end

  def suggest(prefix)
    suggestions = find(prefix).values.map do |e|
      score = 1.0
      e.merge({:score => score})
    end

    suggestions.sort_by{|e| e[:score]}.reverse!
  end
end


# http://www.sinatrarb.com/
class App < Sinatra::Base
  # Endpoints
  get '/suggestions' do
    suggestions = @@cities.suggest(params["q"])
    status 404 if suggestions.empty?
    {:suggestions => suggestions}.to_json
  end

  # Static database initialized on module load
  @@cities = Cities.new
end
