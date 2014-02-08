$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sinatra/base'
require 'json'
require 'lib/parse_datas'
require 'lib/suggestion'
require 'redis'

file   = File.join(File.dirname(__FILE__), "data", "cities_canada-usa.tsv")
$cities = ParseDatas.get_datas_from_csv(file)

# http://www.sinatrarb.com/
class App < Sinatra::Base
  configure :production do
    uri    = URI.parse(ENV["REDISCLOUD_URL"])
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  configure :test do
    $redis = Redis.new(url: ENV["WERCKER_REDIS_URL"], driver: :hiredis)
  end

  configure :development do
    $redis = Redis.new()
  end

  get '/suggestions' do
    redis_cache_key_for(request.fullpath) do
      suggestion = Suggestion.new($cities, params)

      halt 404, suggestion.errors if suggestion.errors?

      {"suggestions" => suggestion.results}
    end
  end

  def redis_cache_key_for(key, &block)
    results = if $redis.exists(request.fullpath)
      JSON.parse($redis.smembers(request.fullpath).first)
    else
      results = yield

      $redis.sadd(request.fullpath, results.to_json)
      results
    end

    halt 404, results.to_json if results["suggestions"].empty?

    results.to_json
  end
end
