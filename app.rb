$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sinatra/base'
require 'json'
require 'lib/parse_datas'
require 'lib/suggestion'

file   = File.join(File.dirname(__FILE__), "data", "cities_canada-usa.tsv")
$cities = ParseDatas.get_datas_from_csv(file)

# http://www.sinatrarb.com/
class App < Sinatra::Base

  get '/suggestions' do
    suggestion = Suggestion.new($cities, params)

    halt 404, suggestion.errors if suggestion.errors?

    suggestions = suggestion.results
    halt 404, {:suggestions => []}.to_json if suggestions.empty?

    suggestions = {:suggestions => suggestions}.to_json
  end
end
