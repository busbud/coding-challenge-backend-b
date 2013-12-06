require './config/environment'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :db do
  namespace :schema do
    task :load do
      City.auto_migrate!
    end
  end

  task :migrate do
    City.auto_upgrade!
  end

  task :populate => 'schema:load' do
    require './geoname_parser'

    lines = File.read('data/cities_canada-usa.tsv')
    data = GeonameParser.parse(lines)

    data.each do |record|
      GeonameParser.build_city(record).save!
    end
  end
end
