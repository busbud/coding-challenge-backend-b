require 'bundler'
Bundler.setup

APP_ROOT = File.expand_path("../", File.dirname(File.join(__FILE__)))
RACK_ENV = ENV['RACK_ENV'] || "development";

$LOAD_PATH.unshift(APP_ROOT)

require 'data_mapper'
DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{APP_ROOT}/db/#{RACK_ENV}.db")

require 'city'
DataMapper.finalize

case RACK_ENV
when "development", "production"
  # We run the migrations if not runned
  City.auto_upgrade!
when "test"
  # We recreate the database with the schema from scratch
  City.auto_migrate!
else
  raise "Invalid RACK_ENV #{RACK_ENV}"
end
