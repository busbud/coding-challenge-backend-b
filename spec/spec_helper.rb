ENV['RACK_ENV'] = 'test'
require './config/environment'

require 'rspec'
require 'rack/test'
require 'json'

require 'pry'
require 'pry-nav'

require 'app'

# Add an #app method for Rack::Test
module TestHelpers
  def app
    App
  end
end

# Monkey patch to simplify parsing json responses
class Rack::MockResponse
  def json_body
    @json_body ||= JSON.load(body)
  end
end

# http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.order = 'random'

  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.include TestHelpers
  config.include Rack::Test::Methods
end
