$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sinatra/base'
require 'json'
require 'lib/parse_datas'

file   = File.join(File.dirname(__FILE__), "data", "cities_canada-usa.tsv")
$cities = ParseDatas.get_datas_from_csv(file)

# http://www.sinatrarb.com/
class App < Sinatra::Base
  suggestion = Suggestion.new(cities)

  get '/suggestions' do
    status 404
    {:suggestions => []}.to_json
  end
end
