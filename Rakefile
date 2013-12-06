require 'bundler'
Bundler.setup

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :populate_db do
  require './geoname_parser'
  
  lines = File.read('data/cities_canada-usa.tsv')
  data = GeonameParser.parse(lines)

  data.each do |record|
    GeonameParser.build_city(record).save!
  end
end

